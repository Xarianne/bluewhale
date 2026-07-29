# A note on running just commands

Since I have my own just commands, I cannot run `just build` as shown in the setup.md. The commands need to point to the Justfile in the Bluewhale home directory. So once you CDed in Bluewhale a build command would look like this: `just -f ./Justfile build`.
