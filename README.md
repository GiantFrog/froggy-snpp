# Froggy SNPP

A basic SNPP terminal client written in crystal.

## Why, though?

Why would anyone in the year of our lord 2022 create an application for pagers? Mostly, the number 444 was important to my childhood, and one day I was curious about what ran on the port that comes after the legendary port 443. I want to learn crystal, I saw GitHub had some SNPP libraries in other languages but no good terminal applications, and this gave me something sort of useful I could create!

As for what to use it for.. Of course you could use it for its intended purpose and send messages to real pagers using a carrier's server, but a more relevant use might be to send text messages to cell phones from your terminal using a service such as [2sms](https://us.2sms.us/2020/07/06/snpp/). You could also use it with some sort of self-hosted pager system, which would be fascinating!

## Installation

### Compiling it Yourself

Ensure you have [Crystal](https://crystal-lang.org/) installed, clone the project, and run `crystal build src/froggy-snpp.cr --release --no-debug`. It'll generate a cool executable to run, just for you!

### Running a Prebuilt Executable

Under [releases](https://github.com/GiantFrog/froggy-snpp/releases), look for a file that matches the system you are using. Download it, rename it with `mv filename froggy-snpp` ensure it is executable with `chmod +x froggy-snpp`, and run it with `./froggy-snpp`, at least on linux/mac. I'll put anything I happen to compile up there, but I won't make a point to compile this thing on every system known to man, so you're better off compiling it yourself if you are able.

## Usage

The only flags that are required and won't prompt for information if not set are `-s` and `-p`. They assume the SNPP server you want to contact is on localhost using port 444, so be sure to set them to a real SNPP server instead if you need to. If a login is required, be sure to set `-u` as well. You'll normally be prompted for a password if a user is set, but you can set the password with `-P`. Do this in conjunction with `-n` for the pager ID and `-m` for the message body to run the program with no user input needed, if you'd like to automate it! Run `froggy-snpp -h` for more details on every flag.

## Missing Features

Not all commands defined in RFC 1861 are implemented by this software. If there exists one you need or would actually use, by all means, open an issue and I will implement it for you! I just don't expect anyone to actually use this, so I'm only working on the things I personally care about.
