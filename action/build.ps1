Set-Location $PSScriptRoot
npm install
ncc build -m index.js
Move-Item -Force dist\index.js index.dist.js
Remove-Item -Recurse dist
Remove-Item -Recurse node_modules
