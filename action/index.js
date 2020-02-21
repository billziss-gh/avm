/*
 * action/index.js
 * avm github action
 *
 * Copyright 2020 Bill Zissimopoulos
 */

const core = require('@actions/core');
const exec = require('@actions/exec');

async function run()
{
    try
    {
        const files = core.getInput('files', {required: true});
        const args = ["-File", __dirname + "\\..\\avm.ps1", "scan"].concat(files.split(/\r?\n/));
        await exec.exec("powershell.exe", args);
    }
    catch (error)
    {
        core.setFailed(error.message);
    }
}

run()
