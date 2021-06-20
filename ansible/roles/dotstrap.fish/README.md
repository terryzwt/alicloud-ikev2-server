ansible-fish
============
[![Build Status](https://travis-ci.org/dotstrap/ansible-fish.svg)](https://travis-ci.org/dotstrap/ansible-fish)

Install & configure the [fish] shell.

Installation
------------

```
ansible-galaxy install dotstrap.fish
```

Requirements
------------

A system package manager.

Role Variables
--------------

See [default variables].

Dependencies
------------

None.

Example Playbook
----------------

Using all the [default variables]:

```
    - hosts: all
      roles:
         - role: dotstrap.fish
```

Notes
-----

__Warning__: This role will change your default shell to [fish].

License
-------

MIT

Author Information
------------------

[@mwilliammyers]


[@mwilliammyers]: https://github.com/mwilliammyers
[default variables]: defaults/main.yml
[dotstrap]: https://github.com/mwilliammyers/dotstrap
[files]: files/
[fish]: http://fishshell.com/
[homebrew]: https://github.com/Homebrew/homebrew
[template]: templates/config.j2
[variables]: vars/main.yml
[zsh]: http://zsh.sourceforge.net
