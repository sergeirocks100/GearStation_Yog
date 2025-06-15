# CONTRIBUTING

1. [Reporting Issues](#reporting-issues)
2. [Introduction](#introduction)
3. [Getting Started](#getting-started)
4. [Legal Notice](legal-notice)
5. [Meet the Team](#meet-the-team)
	1. [Headcoder](#head-developer)
	2. [Maintainers](#maintainers)
6. [GearStation GitHub Guidelines](#gearstation-github-guidelines)
7. [Development Guides](#development-guides)
8. [Pull Request Process](#pull-request-process)
9. [Porting features/sprites/sounds/tools from other codebases](#porting-featuresspritessoundstools-from-other-codebases)
10. [Restricted content](#restricted-content)
11. [Banned content](#banned-content)
12. [A word on Git](#a-word-on-git)
12. [A word on changelogs](#a-word-on-changelogs)

## Reporting Issues

See [this page](http://tgstation13.org/wiki/Reporting_Issues) for a guide and format to issue reports.

## Introduction

Hello and welcome to GearStation's contributing page. You are here because you are curious or interested in contributing - thank you! Everyone is free to contribute to this project as long as they follow the simple guidelines and specifications below; at GearStation, we strive to maintain code stability and maintainability, and to do that, we need all pull requests to hold up to those specifications. It's in everyone's best interests - including yours! - if the same bug doesn't have to be fixed twice because of duplicated code.

First things first, we want to make it clear how you can contribute (if you've never contributed before), as well as the kinds of powers the team has over your additions, to avoid any unpleasant surprises if your pull request is closed for a reason you didn't foresee.

## Getting Started

GearStation doesn't have a list of goals and features to add; we instead allow freedom for contributors to suggest and create their ideas for the game. That doesn't mean we aren't determined to squash bugs, which unfortunately pop up a lot due to the deep complexity of the game. Here are some useful starting guides, if you want to contribute or if you want to know what challenges you can tackle with zero knowledge about the game's code structure.

If you want to contribute the first thing you'll need to do is [set up Git](https://gearstation.space/wiki/Setting_up_git) so you can download the source code.

We have a [list of guides on the wiki](https://gearstation.space/wiki/Guides#Development_and_Contribution_Guides) that will help you get started contributing to GearStation with Git and Dream Maker. For beginners, it is recommended you work on small projects like bug fixes at first. If you need help learning to program in BYOND, check out this [repository of resources](http://www.byond.com/developer/articles/resources).

You can of course, as always, ask for help in the #development channel on the [discord](https://discord.gg/DCddpQ5MzM). We're just here to have fun and help out, so please don't expect professional support.

## Legal Notice

When it comes to original, from scratch contributions, by opening a pull request on GearStation, you (And any co-contributors) agree to license your code contributions under the [GNU AGPL V3](https://www.gnu.org/licenses/agpl-3.0.html), and other forms of contributions (Icons, sounds, maps, etc.) under [Creative Commons BY-SA 3.0](https://creativecommons.org/licenses/by-sa/3.0/).

You also agree that, unless you specify otherwise in the pull request, that the Github usernames of the contributors involved, along with a link back to the pull request, are how you should be credited if someone were to port your contributions, or otherwise make use of them in ways where credit is required.

To put it simply, by contributing to GearStation, you agree to allow others to use and modify your contributions as they see fit, including for commercial purposes, as long as they give you credit, and make the source code (if any) public.

If you don't want people to freely reuse and modify your contributions, don't contribute to GearStation. We wish for people to feel safe in porting and modifying things from the codebase, without having to track down and ask permission from contributors for things the license should already give them permission to do.

When it comes to contributions you didn't make entirely yourself (Ports from other codebases, use of outside code or assets, etc.), refer to the [porting guidelines](#porting-featuresspritessoundstools-from-other-codebases).

## Meet the Team

### Headcoder

The Headcoder(s) are responsible for controlling, adding, and removing maintainers from the project. In addition to filling the role of a normal maintainer, they have sole authority on who becomes a maintainer, as well as who remains a maintainer and who does not.

### Maintainers

Maintainers are quality control. If a proposed pull request doesn't meet the specifications laid out in this document, they can request you to change it, or simply just close the pull request. Maintainers are required to wait 24 hours before closing a pull request, and must give a reason for closing the pull request.

Maintainers can revert your changes if they feel they are not worth maintaining or if they did not live up to the quality specifications.

## GearStation GitHub Guidelines

### General Rules

**GearStation is an open source community-driven project that allows everybody to contribute their ideas towards making rounds on Space Station 13 as fun as possible by means of pull requests and issue reports to the main repository.**

**Although we allow conversation on GitHub in Pull Requests/Issues, we ask that all contributors and maintainers maintain a sense of decorum and respect the author and other people contributing to the discussion.** If someone is constantly contributing negative statements or is not constructive in their criticism they may be asked to stop or have their right to contribute removed in the future.

**The GitHub Terms and Conditions must be followed.** Failure to follow the terms and conditions of GitHub may result in your exclusion from contribution in the future. 

**We do not require people to be signed up on the forums or Discord in order to contribute to the GitHub; however, there must be a way for maintainers to be able to contact you, either via Discord (preferably) or e-mail when concerns with identity are found and need to be resolved.** Being banned from the server does not automatically ban you from GitHub and vice versa; however, this is up to the discretion of the Headcoders. Your pull requests may all be placed on hold until you accept this request for communication.

### Contributors

**When you are creating a Pull Request/Issue Report**, please make sure you name the Pull Request/Issue something relevant to what is being changed, added, or removed. Do not attempt to mislead people about the content of the Pull Request/Issue. Make sure you fill out any applicable templates as clearly and concisely as possible, and link any relevant issues your Pull Request solves.

**We do not limit the amount of Pull Requests which can be submitted per day**; however, please do not submit more than is necessary. Additionally, please do not harass any member of the development team to expedite or merge your Pull Request. In certain circumstances, such as the case of a game breaking bug or issue, please reach out and inform them as soon as possible.

**We allow users to create draft Pull Requests in order to have time to work on features and solicit feedback on those features**; however, there will be a limit of 2 draft Pull Requests per person, as we want people to finish their projects before moving onto others as soon as possible.

**In regards to Revert Pull Requests**, these should only be opened if there is a reason for the reversion ie. the feature is broken or is not as expected when it was merged. Otherwise please wait at least 48 hours before reversing a change. These rules do not apply to corrections made by a HD for a Pull request merged by a maintainer incorrectly or if they disagree it should have been merged in the first place.

### Maintainers

**As a maintainer, you are a representative of the development team, as such you should act with a somewhat professional manner when dealing with contributions, including constructively commenting on PRs.**

**All maintainers should follow set standards for handling Pull Requests.** These standards include waiting 24 hours before merging or closing a Pull Request, as well as merging only Pull Requests that fall under your area of expertise (i.e. an Art Maintainer should not merge code, and a Code Maintainer should not merge art.) Lastly, revert Pull Requests should only be merged by a Headcoder. The above limitations do not apply to round-breaking or repo-breaking changes; however, please notify any Headcoders if this occurs.

**All maintainers should encourage discourse and collaboration.** As such, maintainers should only close Pull Requests if:
* It is a draft Pull Request and the contributor has more than 2 draft Pull Requests open, in which the oldest draft Pull Request should be closed until the author closes another.
* It is a Pull Request that has content that falls under the banned content guidelines, and the issue isn't rectified within 24 hours.
* It is a Pull Request that was opened with inadequate rationale or is lacking proper naming or violates existing guidelines in some way.


**If a maintainer gets banned from the server/Discord, there will be an automatic review process triggered.** During this time access to GitHub merging and in-game ranks will be removed until the review is complete. After this review, roles and permissions may be returned depending on the result.

### Contributor-Maintainer Disputes

**If you have any complaints about maintainers or contributors you can use the GitHub report function**; however, abuse of this feature will be addressed if needed.

**You may also raise an issue on discord by going to the #development channel and creating a private thread**, then pinging a Headcoder to make sure they are notified.

**These policies are enforced by the Headcoder(s) and are subject to change at their discretion, with or without notification to the general public.**

## Development Guides

#### Writing readable code 
[Style guide](./guides/STYLE.md)

#### Writing sane code 
[Code standards](./guides/STANDARDS.md)

#### Writing understandable code 
[Autodocumenting code](./guides/AUTODOC.md)

#### Misc

- [Embedding TGUI Components in Chat](../../tgui/docs/chat-embedded-components.md)
- [Hard Deletes](./guides/HARDDELETES.md)
- [Quickly setting up a development database with ezdb](./guides/EZDB.md)
- [MC Tab Guide](./guides/MC_tab.md)
- [Tick system](./guides/TICK_ORDER.md)
- [UI Development](../tgui/README.md)

## Pull Request Process

There is no strict process when it comes to merging pull requests. Pull requests will sometimes take a while before they are looked at by a maintainer; the bigger the change, the more time it will take before they are accepted into the code. Every team member is a volunteer who is giving up their own time to help maintain and contribute, so please be courteous and respectful. Here are some helpful ways to make it easier for you and for the maintainers when making a pull request.

* Make sure your pull request complies to the requirements outlined in [this guide](http://tgstation13.org/wiki/Getting_Your_Pull_Accepted)

* You are going to be expected to document all your changes in the pull request. Failing to do so will mean delaying it as we will have to question why you made the change. On the other hand, you can speed up the process by making the pull request readable and easy to understand, with diagrams or before/after data.

* We ask that you use the changelog system to document your player facing changes, which prevents our players from being caught unaware by said changes - you can find more information about this [on this wiki page](http://tgstation13.org/wiki/Guide_to_Changelogs).

* If you are fixing a game-breaking bug, it's advised to use the [s] tag to not bring unwanted attention to your pull request. Very rarely is it acceptable to use this label outside of these situations, due to it hiding information from many sources.

* If you are proposing multiple changes, which change many different aspects of the code, you are expected to section them off into different pull requests in order to make it easier to review them and to deny/accept the changes that are deemed acceptable.

* If your pull request is accepted, the code you add no longer belongs exclusively to you but to everyone; everyone is free to work on it, but you are also free to support or object to any changes being made, which will likely hold more weight, as you're the one who added the feature. It is a shame this has to be explicitly said, but there have been cases where this would've saved some trouble.

* Please explain why you are submitting the pull request, and how you think your change will be beneficial to the game. Failure to do so will be grounds for rejecting the PR.

* If your pull request is not finished make sure it is at least testable in a live environment. Pull requests that do not at least meet this requirement will be closed. You may request a maintainer reopen the pull request when you're ready, or make a new one.

* While we have no issue helping contributors (and especially new contributors) bring reasonably sized contributions up to standards via the pull request review process, larger contributions are expected to pass a higher bar of completeness and code quality *before* you open a pull request. Maintainers may close such pull requests that are deemed to be substantially flawed. You should take some time to discuss with maintainers or other contributors on how to improve the changes.

* Any PR submitted after February 13th, 2024 must be accompanied by giving visual evidence (images, gifs, videos) of testing if the changes in the PR have any visual indication of changes. Omitting or filling out the testing part of the template with "I tested it" does not show these changes. Maintainers may hold your PR until testing is provided at the discretion of the Headcoders.

## Porting features/sprites/sounds/tools from other codebases

If you are porting features/tools from other codebases, you must give them credit where it's due. Typically, crediting them in your pull request and the changelog is the recommended way of doing it. Take note of what license they use, though; ports from codebases licensed under the AGPLv3, as well as the GPLv3, are permitted
Regarding sprites & sounds, you must credit the artist and possibly the codebase. All GearStation assets including icons and sound are under a [Creative Commons BY-SA 3.0 license](https://creativecommons.org/licenses/by-sa/3.0/) unless otherwise indicated.

Because GearStation is a codebase that believes in software freedom. assets or code that are under non-free licenses (such as the [Creative Commons BY-NC-SA 3.0 license](https://creativecommons.org/licenses/by-nc-sa/3.0/) that GoonStation and BurgerStation use) are banned from use on GearStation. If there are assets in something that you want to port that make use of non-free licenses, you may either:

A: Replace all of the offending assets with ones that you created yourself, or are otherwise under a license that GearStation accepts.

B: Get written permission from the original creator(s) to sublicense the assets under Creative Commons BY-SA 3.0, or, failing that, another license that GearStation accepts. Be sure that you get it sublicensed under an actual license; simply getting a "Hey, you can use this." or something similar won't be enough.

When it comes to code that's under non-free licenses, you should follow similar procedures. You should strongly considier rewriting the offending code from scratch instead of getting it sublicensed, as most codebases that are under non-free licenses are strongly divorced from other codebases in their programming practices, and it may take more work to try to make it work on our code than it would to just recreate it from the ground up.

However, if you wish to do so, you may try to obtain written permission to sublicense the offending code under the AGPLv3, or, failing that, another license that GearStation accepts.

The GNU website has a helpful list of free and non-free licenses [here](https://www.gnu.org/licenses/license-list.en.html).

## Restricted content
Adding any of the following in a Pull Request requires prior approval from a maintainer or headcoder:
* Code adding, removing, or updating the availability of alien races/species/human mutants. Pull requests attempting to add or remove features from said races/species/mutants require prior approval as well.
* Station maps consisting of more than one Z-level.

## Banned content
Do not add any of the following in a Pull Request, or risk getting it closed:
* Code where one line of code is split across multiple lines (except for multiple, separate strings and comments; in those cases, existing longer lines must not be split up.).
* Any assets or code that are under non-free licenses.
* Anything that relies on Extools, Auxtools, or any other BYOND version dependent external DLLs to function.
* Anything that contains in-game references to real world news events, popular culture, or internet memes. This also applies to references to the game itself, such as the players, admins, developers, or community happenings of GearStation and other SS13 codebases.
* Anything that's meant to generate or spread real world bigotry or prejuidice.
* Code which violates GitHub's [terms of service](https://github.com/site/terms).

Just because something isn't on this list doesn't mean that it's acceptable. Use common sense above all else.

## A word on Git
All .dmm, .dm, .md, .txt, and .html files are required to end with CRLF(DOS/WINDOWS) line endings. Git will enforce said line endings automatically. Other file types have non enforced line endings.

## A word on changelogs
Please don't format changelog entries in a way where the changelog prefix forms the first word of a sentence, for example:

```
add: something to the game
```

The changelog prefix isn't going to display as text once the changelog is compiled and put into the game, and so the result is going to look confusing and grammatically incorrect:

```
✅: something to the game
```

To avoid situations like this, format your changelogs in a way where the description forms a complete sentence by itself, like this:

```
add: added something to the game
```

That way, it'll look correct once it's compiled:

```
✅: added something to the game
```
