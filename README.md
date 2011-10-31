# knife-bulkchangeenv

A plugin for Chef::Knife which lets you move all nodes in one environment into another.

## Preface

Searches for all nodes in a particular environment and moves them to another

## What it does

knife node bulk_change_environment "_default" development
will move all nodes in the default environment (in quotes because of the underscore) into the development environment.

## Notes
Please be careful when using this plugin, especially if you're already using environments with version constraints configured. You don't want all your nodes moved to the wrong one by mistake!

