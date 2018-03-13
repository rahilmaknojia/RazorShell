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

will output this:

```html
<h1>Hi jbockle!</h1>

<ul><li>item1</li><li>item2</li><li>item3</li></ul>

<table>
    <tr>
        <td>Name</td>
        <td>Priority</td>
    </tr>
    <tr>
        <td>aciseagent</td>
        <td></td>   
    </tr>
    <tr>
        <td>audiodg</td>
        <td></td>   
    </tr>
    <tr>
        <td>chrome</td>
        <td>Idle</td>   
    </tr>
    <tr>
        <td>chrome</td>
        <td>Idle</td>   
    </tr>
    <tr>
        <td>chrome</td>
        <td>Normal</td>   
    </tr>
    <tr>
        <td>chrome</td>
        <td>Idle</td>   
    </tr>
    <tr>
        <td>chrome</td>
        <td>Idle</td>   
    </tr>
    <tr>
        <td>chrome</td>
        <td>Normal</td>   
    </tr>
    <tr>
        <td>chrome</td>
        <td>Idle</td>   
    </tr>
    <tr>
        <td>chrome</td>
        <td>Normal</td>   
    </tr>
</table>
```

