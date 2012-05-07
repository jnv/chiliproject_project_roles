# Project Roles plugin for ChiliProject [![Build Status](https://secure.travis-ci.org/jnv/chiliproject_project_roles.png?branch=master)](http://travis-ci.org/jnv/chiliproject_project_roles)

Provides per-project roles and workflows. Both local and global roles can be assigned to anonymous and non-member users. This function is heavily inspired by [Role Shift plugin](http://projects.andriylesyuk.com/projects/role-shift).

Project roles are available to subprojects, but cannot be edited from there.

## Installation

1. Follow the instructions at https://www.chiliproject.org/projects/chiliproject/wiki/Plugin_Install
2. New tabs "Roles" and "Workflows" will appear in Project Settings
3. Add "Manage project roles" permission to roles (preferably project maintainers)

## Dependencies

Plugin depends on the [MembersView](https://github.com/jnv/chiliproject_members_view) gem. It will be picked by `bundle install`.

## Compatibility

Plugin was tested with ChiliProject 3.1.0 and Ruby 1.9.3.

## Development and testing

Patches, pull requests and forks are welcome, but if possible, provide proper test coverage.

Test suite uses [Shoulda](https://github.com/thoughtbot/shoulda/tree/v2.10.3) and [Object Daddy](https://github.com/edavis10/object_daddy).

To run tests, follow [Redmine's instructions](http://www.redmine.org/projects/redmine/wiki/Plugin_Tutorial#Initialize-Test-DB).

Due to [Engines compatibility bug](https://www.chiliproject.org/issues/944) the test suite won't work under Ruby 1.9 with standard ChiliProject distribution. You can replace ChiliProject's engines with [fixed version](https://github.com/jnv/engines).

You can also use [Travis-CI](http://travis-ci.org/) integration based on the [chiliproject_test_plugin](https://github.com/jnv/chiliproject_test_plugin).

## License

This plugin is licensed under the GNU GPL v2. See COPYRIGHT.txt and LICENSE.txt for details.
