Set-Location $PSScriptRoot
npm install
ncc build -m action.js
Move-Item -Force dist\index.js action-dist.js
Remove-Item -Recurse dist
Remove-Item -Recurse node_modules
