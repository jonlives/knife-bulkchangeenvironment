# knife-bulkchangeenv

A plugin for Chef::Knife which lets you move all nodes in one environment into another.

## GEM INSTALL
knife-bulkchangeenvironment is available on rubygems.org - if you have that source in your gemrc, you can simply use:

````
gem install knife-bulkchangeenvironment
````

## Preface

Searches for all nodes in a particular environment and moves them to another

## What it does

````
knife node bulk_change_environment "_default" development
````

will move all nodes in the default environment (in quotes because of the underscore) into the development environment.

### With a query
````
knife node bulk_change_environment "_default" development 'platform:ubuntu'
````

will move all nodes in the default environment that also match the query "platform:ubuntu" to the development environment. Useful when you only need to move a subset of nodes.

## Notes
Please be careful when using this plugin, especially if you're already using environments with version constraints configured. You don't want all your nodes moved to the wrong one by mistake!

