<!--
  Copyright 2020-2022 Zeek-Kafka

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
      http://www.apache.org/licenses/LICENSE-2.0
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
-->
# Maintainers Guide

This guide is intended for maintainers — anybody with commit access to the
`zeek-kafka` repository.

## Releases

All `zeek-kafka` releases first have a release candidate prior to being
promoted to general availability.

In order to create a release, you must have `pipenv` and `python3` installed,
and then run the following commands, where `$TYPE` is one of `major`, `minor`,
`patch`, `build`, or `release`.

```bash
TYPE=major
REMOTE=origin

git checkout main
git pull $REMOTE main
pipenv run invoke version $TYPE
git push --atomic $REMOTE $(git branch --show-current) $(git tag --points-at HEAD)
```

The previous commands result in a tagged commit containing updated version
references in `zkg.meta` and `README.md` (as defined in `setup.cfg`) being
pushed to GitHub, at which point GitHub actions performs the remaining release
actions based on `.github/workflows/release.yml` and
`.github/workflows/prerelease.yml`.

### Promoting a RC to GA

After a release candidate has been published for one week, assuming no new
issues have been discovered, a final release can be published. Follow the prior
steps with a `TYPE` of `release`.

If a release candidate has known issues, the maintainers can decide whether to
release anyway, or contribute additional to mitigate or resolve the issue and
increment the `build` and issue a new release candidate.

### Announcing

After creating a release or release candidate, consider announcing it to the following areas:

- The [Zeek Slack workspace](zeekorg.slack.com)
- The [Zeek user mailing list](https://lists.zeek.org/mailman3/lists/zeek.lists.zeek.org/)
- Twitter, using #Zeek and #Kafka
