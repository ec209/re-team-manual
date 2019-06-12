# YubiKeys

Anyone with production access, which includes most (if not all) of Reliability
Engineering, should be using a GDS issued [YubiKey] for:

* storage of [GPG] keys:
  * signatures
  * encryption
  * authentication
* ssh keys (e.g. for GitHub or SSH access)

In addition, it is advisable to use the YubiKey for:

* Time-based One Time Passwords (TOTPs)
* Universal 2nd Factor (U2F) authentication

## How to setup YubiKey for GPG

We will generate the GPG key directly on the YubiKey you have received. This
means that the private key cannot be exported at any point from now on, and
will not be generated (or left behind) on your machine.

> Generating the PGP on the YubiKey ensures that malware can never steal your
> PGP private key. However, this means that the key can not be backed up so if
> your YubiKey is lost or damaged the PGP key is irrecoverable.

### Requirements

You will need to install certain applications on your system.

If you have [homebrew] installed on your Mac, run the following:

```sh
brew install ykman gnupg coreutils pinentry-mac
```

Add the following line to your `.bash_profile`:

```sh
export GPG_TTY=$(tty)
```

This will ensure your GPG sessions happen in the terminal instead of relying on
the GUI.

#### (Optional) YubiKey preparation

If you have set up GPG on your YubiKey before, you may need to reset the Key.
Make sure your YubiKey is connected to your laptop.

Run the following command to clear all GPG data currently residing on your key.

```sh
ykman openpgp reset
```

This command will also print out your PINs. Make a note of them.

### Setup GPG on YubiKey

You may be asked for a PIN whilst running through the following instructions.
The default PINs are:

- user: `123456`
- admin: `12345678`

Follow these steps to setup the GPG on your YubiKey.

1. Insert the YubiKey into the USB port.
1. Open Terminal.
1. Enter the GPG command: `gpg --card-edit`
1. At the `gpg/card>` prompt, enter the command: `admin`
1. Enter the command: `generate`
1. When prompted, specify if you want to make an off-card backup of your
   encryption key. We recommend that you say `no`. It brings no value.
1. Specify how long the key should be valid for (specify the number in days,
   weeks, months, or years). We recommend to say `0` to make sure the key never
   expires.
    - This may prompt you to enter a **user** PIN.
1. When prompted, enter your name, email address and comment. We recommend that
   it is GDS specific.
    - Real Name: `Rafal Proszowski`
    - Email address: `rafal.proszowski@digital.cabinet-office.gov.uk`
    - Comment: `GDS`
1. Review the name, email, and accept or make changes.
    - This may prompt you to enter an **admin** PIN.
1. Enter the default admin PIN again. **The green light on the YubiKey will
   flash while the keys are being written.**
1. You should change the two PINs on the key, to make sure a lost key doesn't
   allow new owner to sign in or decrypt data with your key. Type in `passwd`
   and follow the steps on the screen. Press `Q` to quit interactive mode.
    **TIP:** although it's called a "PIN" it can in fact be any alphanumeric
    passphrase
3. Enter `quit` to finish setting up the key.

### Publish public key to keyservers

1. Obtain the Key fingerprint and Key ID by running:
    ```
    gpg -K --keyid-format 0xLONG
    ```
    - `Key ID` is the 18 character string after `rsa2048/` on the first line of
      the output.
    - `Key fingerprint` (if present) is the 40 character string in the
      second line of the output.
1. Publish your public key by running:
    ```
    gpg --keyserver keys.gnupg.net --send-keys <KEY_ID>
    ```
    - These servers can be unreliable. If it fails, try again or try with
      different server, for instance `pgp.mit.edu`.

### Publish public key to GitHub and configure git

You should add the public key to GitHub to identify your commits with GPG
signatures.

1. Obtain the Key fingerprint and Key ID by running
    ```
    gpg -K --keyid-format 0xLONG
    ```
    - `KEY_ID` is the 18 character string after `rsa2048/` on the first line of
      the output.
      For example: `0x0000000000000000`
    - `Key fingerprint` (if present) is the 40 character string
      For example: `0000 0000 0000 0000 0000  0000 0000 0000 0000 0000`
1. Run the following command to obtain your public key:

    ```sh
    gpg --armor --export <KEY_ID>
    ```

    **TIP:** Pipe output of above command into `pbcopy` to copy the output to
    your system clipboard ready for pasting.
1. [Go to GitHub settings](https://help.GitHub.com/en/articles/adding-a-new-gpg-key-to-your-GitHub-account)
   to add the public key output above to your GitHub account.
1. Add or update the `[User]` section in your `~/.gitconfig` file similar to
   the example below to configure git to use the key for signing commits
   .`signingkey` should be set to your <KEY_ID> from above.

    ```
    [user]
        name = Rafal Proszowski
        email = rafal.proszowski@digital.cabinet-office.gov.uk
        signingkey = <KEY_ID>

    ```
1. (Optional) Set git to _always_ sign commits:
    ```
    git config --global commit.gpgsign true
    ```
### (Optional) Tuning GPG agent

You should create any files that do not exist yet.

These will provide a better user experience and some security.

_~/.gnupg/gpg.conf_

```
auto-key-locate keyserver
keyserver hkps://hkps.pool.sks-keyservers.net
keyserver-options no-honor-keyserver-url
personal-cipher-preferences AES256 AES192 AES CAST5
personal-digest-preferences SHA512 SHA384 SHA256 SHA224
default-preference-list SHA512 SHA384 SHA256 SHA224 AES256 AES192 AES CAST5 ZLIB BZIP2 ZIP Uncompressed
cert-digest-algo SHA512
s2k-cipher-algo AES256
s2k-digest-algo SHA512
charset utf-8
fixed-list-mode
no-comments
no-emit-version
keyid-format 0xlong
list-options show-uid-validity
verify-options show-uid-validity
with-fingerprint
use-agent
require-cross-certification
```

_~/.gnupg/gpg-agent.conf_

```
enable-ssh-support
pinentry-program /usr/local/bin/pinentry-mac
default-cache-ttl 60
max-cache-ttl 120
```

After setting up these `.conf` files for GPG, you should kill the agent:

```sh
killall gpg-agent
```
## Use YubiKey for 2FA in GitHub account

You can use your YubiKey as your 2FA device for GitHub. This is more
convenient (insert key and press the gold disk when prompted) and more
secure than an authenticator app on your phone:

1. Visit your [GitHub account settings](https://GitHub.com/settings/two_factor_authentication/configure) to add your YubiKey as a U2F device.

## Use YubiKey for 2FA in Google account

You can use your YubiKey as your 2FA device for Google Account.

1. Visit your [google account settings](https://myaccount.google.com/signinoptions/two-step-verification) to add your YubiKey as a Security Key

## Troubleshooting

If the YubiKey is inserted but you still get errors like this:

```
error: gpg failed to sign the data
fatal: failed to write commit object
```

When trying to `git commit`, there are a couple of things you should check.

First, check that GnuPG can read the right private key off your YubiKey, with:

```shell=bash
gpg --card-status
```

Look for a line starting with `sec>` and make sure it shows the key ID that
you've specified in your Git configuration.

Next, in case the GnuPG agent is attempting to use the wrong TTY, try:

```shell=bash
export GPG_TTY=$(tty)
```

Now to test that everything's working you can try signing some text:

```shell=bash
echo "test" | gpg --clearsign
```

If you're trying to change the Admin PIN and getting an error like "Conditions of use not satisfied", this means your new PIN is less than 8 characters.

[YubiKey]: https://www.yubico.com/
[GPG]: https://www.gnupg.org/
[homebrew]: https://brew.sh/

