# My Mac Configuration

I use [Chezmoi](https://chezmoi.io) to manage my Mac's configuration and
[Homebrew](https://brew.sh) to install software. This setup includes developer tools,
shell customizations, and system preferences tailored for Apple Silicon Macs.

This configuration is stored in the GitHub
[jcouball/dotfiles](https://github.com/jcouball/dotfiles) repository.

## Quick Start

To provision a new, freshly installed Apple Silicon Mac run:

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/jcouball/dotfiles_neuromancer/main/provision.sh)"
```

There are no prerequisites other than the macOS operating system itself.

> ⚠️ **Caution**
>
> Make sure to review the provisioning script
> [provision.sh](https://github.com/jcouball/dotfiles_neuromancer/blob/main/provision.sh)
> before running it. It makes system-level changes, installs developer tools, and
> customizes your environment.

## System Requirements

Tested with the following:

- Apple Silicon Mac (M1 or newer)
- macOS Sequoia (15) or later
- Internet connection

## License

This project is licensed under the [MIT License](LICENSE.txt).

## Contributing

Feel free to fork this repository and adapt it to your own needs. If you spot something useful to upstream, I’m open to contributions.