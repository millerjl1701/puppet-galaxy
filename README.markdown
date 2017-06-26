#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with galaxy](#setup)
    * [What galaxy affects](#what-galaxy-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with galaxy](#beginning-with-galaxy)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

This module installs and configures a galaxy instance.

## Module Description

Galaxy is "an open, web-based platform for accessible, reproducible, and transparent computational biomedical research". (https://galaxyproject.org/) This module helps to simplify the installation, configuration, and service management of a locally installed instance of Galaxy.

## Setup

### What galaxy affects

* A list of files, packages, services, or operations that the module will alter, impact, or execute on the system it's installed on.
* This is a great place to stick any warnings.
* Can be in list or paragraph form.

### Setup Requirements

If your module requires anything extra before setting up (pluginsync enabled, etc.), mention it here.

### Beginning with galaxy

`include '::galaxy'` is enough to get you up and running. To pass in parameters:

```
  class { '::galaxy':
    foo => 'bar',
  }
```

## Usage

All parameters for the galaxy module should be included as part of the `::galaxy` class. If not, then that is a bug and not intended.


## Reference

### Classes

#### Public Classes
* galaxy: Main class which includes all other classes.

#### Private Classes
* galaxy::install: Handles installation of Galaxy
* galaxy::config: Handles configuraitoin files
* galaxy::service: Handles service definitions

#### Parameters
The following parameters are available in the `::galaxy` class:

## Limitations

This module is tested for RHEL/CentOS 7 and the 17.05 version of galaxy. The module is setup with hiera 5 data usage so Puppet 4.9 or higher is neeed.

## Development

New contributions are welcome! Those that include documentation and rspec tests are even more welcome! The module was originally generated using Gareth Rushgrove's puppet-module-skeleton repository (https://github.com/garethr/puppet-module-skeleton). However, the Gemfile is from the VoxPupuli project (https://voxpupuli.org/). The version of ruby for development work with the Gemfile was 2.3.1. Other versions may work with modifications to the Gemfile.
