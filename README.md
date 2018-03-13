# RazorShell

Transform's a razor template to html

## Usage

```powershell
Import-Module RazorShell

$template = @"
<h1>Hi @Model.Name!</h1>

<ul>@foreach(var x in @Model.Items1){<li>@x</li>}</ul>

<table>
    <tr>
        <td>Name</td>
        <td>Priority</td>
    </tr>
    @foreach(var process in @Model.Items2){    
    <tr>
        <td>@process.Name</td>
        <td>@process.PriorityClass</td>   
    </tr>
    }
</table>
"@

$model = [pscustomobject]@{
    Name = 'jbockle'
    Items1 = @(
        'item1','item2','item3'
    )
    Items2 = @(Get-Process | select -first 10)
}

Format-RazorShell -Template $template -Model $model

```

