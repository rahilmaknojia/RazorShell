

$script:namespace = 'RazorShell.Templates'

function Format-RazorTemplate {
    [CmdLetBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Template,

        [Parameter()]
        [object]$Model
    )
    begin {        
        Import-RazorLibrary
    }
    process {
        $TemplateClassName = "t{0}" -f ([System.IO.Path]::GetRandomFileName() -replace "\.", "")
        $TemplateBaseClassName = "t{0}" -f ([System.IO.Path]::GetRandomFileName() -replace "\.", "")

        $templateBaseCode = New-TemplateBaseDefinition -Name $TemplateBaseClassName

        $code = New-TemplateCode -Template $Template -TemplateClassName $TemplateClassName -TemplateBaseClassName $TemplateBaseClassName

        Invoke-Compilation -Code $code -TemplateBaseCode $templateBaseCode

        Invoke-RenderRazorShell -TemplateClassName $TemplateClassName -Model $Model
    }
}

function Import-RazorLibrary {    
    if (!([AppDomain]::CurrentDomain.GetAssemblies() | ? { $_.FullName -match "^System.Web.Razor" })) {
        Add-Type -Path $PSScriptRoot\Libs\System.Web.Razor.dll
    }
}

function New-TemplateBaseDefinition {
    [OutputType([string])]
    [CmdLetBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name

    )
    return @"
        using System;
        using System.Text;
        using Microsoft.CSharp.RuntimeBinder;
        
        namespace $script:namespace {
        
            public abstract class $Name
            {
                protected dynamic Model;
                private StringBuilder _sb = new StringBuilder();
                public abstract void Execute();
                public virtual void Write(object value)
                {
                    WriteLiteral(value);
                }
                public virtual void WriteLiteral(object value)
                {
                    _sb.Append(value);
                }
                public string Render (dynamic model)
                {
                    Model = model;
                    Execute();
                    var res = _sb.ToString();
                    _sb.Clear();
                    return res;
                }
            }
        }
"@
}

function Invoke-Compilation {
    param(
        $Code,

        $TemplateBaseCode
    )
    $stringWriter = New-Object -TypeName System.IO.StringWriter
    $compiler = New-Object -TypeName Microsoft.CSharp.CSharpCodeProvider
    $compilerResult = $compiler.GenerateCodeFromCompileUnit($Code.GeneratedCode, $stringWriter, $null)
    $templateCode = $TemplateBaseCode + "`n" + $stringWriter.ToString()
    Add-Type -TypeDefinition $templateCode -ReferencedAssemblies System.Core, Microsoft.CSharp
}

function New-TemplateCode {
    param(
        $Template,

        $TemplateClassName,

        $TemplateBaseClassName
    )
    $language = New-Object -TypeName System.Web.Razor.CSharpRazorCodeLanguage
    $properties = @{
        DefaultBaseClass = "{0}.{1}" -f $script:namespace, $TemplateBaseClassName;
        DefaultClassName = $TemplateClassName;
        DefaultNamespace = $script:namespace;
    }
    $engineHost = New-Object -TypeName System.Web.Razor.RazorEngineHost($language) -Property $properties
    $engine = New-Object -TypeName System.Web.Razor.RazorTemplateEngine($engineHost)
    $stringReader = New-Object -TypeName System.IO.StringReader($Template)
    return $engine.GenerateCode($stringReader)
}

function Invoke-RenderRazorShell {
    param(
        $TemplateClassName,

        $Model
    )
    $templateInstance = New-Object -TypeName ("{0}.{1}" -f $script:namespace, $TemplateClassName)
    $templateInstance.Render($Model)
}

Export-ModuleMember -Function Format-RazorTemplate