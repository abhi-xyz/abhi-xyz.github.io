+++
title = 'A Gentle Guide to Using Sops-Nix'
tags = ['all', 'nixos', 'linux']
date = 2024-10-17T18:12:59+05:30
+++

Sops-nix might seem complicated at first, but once you dive into it, you'll realize it's much simpler than it appears. In fact, I put off learning it for a while myself, but when I finally sat down to understand it, I had everything up and running in just 30 minutes. The goal of this guide is to help you understand sops-nix as quickly as possible, so let’s break it down step by step.

# Setting up Sops-Nix

## Step 1: Adding sops-nix to your Nix configuration

The first thing we need to do is add the source of sops-nix in the inputs section of your flake.nix. Afterward, we pass it to the outputs.

```nix { .my_codeblock hl_Lines="5-8 14 28 39"}
{
  description = "Abhi's NixOS Configuration";

  inputs = {
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{
    self,
      nixpkgs,
      sops-nix,
      home-manager,
      ...
  }:
  let
    system = "x86_64-linux";
};
in {
  nixosConfigurations."nixos" = nixpkgs.lib.nixosSystem {
    inherit system;
    specialArgs = { inherit inputs; };
    modules = [
      ./hosts/configuration.nix

        sops-nix.nixosModules.sops

        home-manager.nixosModules.home-manager
        {
          home-manager = {
            users.abhi = {
              imports = [
                ./home/home.nix
              ];
            };
            sharedModules = [
              inputs.sops-nix.homeManagerModules.sops
            ];
          };
        }
    ];
  };
};
}
```

At this point, we have full access to the sops-nix functionality in both system-wide and home-manager configurations.

Once you’ve set this up, you can now use sops-nix options anywhere in your configuration files, including configuration.nix, home.nix, and their submodules.

## Step 2: Installing Sops and Age

With sops-nix integrated into your configuration, the next step is to install sops and age, which are the tools that handle encryption and decryption.

```nix
environment.systemPackages = with pkgs; [
  sops
  age
];
```

## Step 3: Generating Your Age Key Pair

Once you've installed age, the next step is to generate an Age key pair. The public key will be used for encrypting secrets, and the private key will be used to decrypt them.

Run the following command to generate a key pair:

```fish
age-keygen -o keys.txt
```

This will create a file keys.txt containing both the public and private keys. Store your private key securely — you can even keep it on a USB drive for additional safety rather than storing it directly on your machine.

# Step 4: Understanding the Role of Sops and Sops-Nix

It’s important to distinguish the roles of sops and sops-nix:

- **Sops**: This is the tool that will handle encrypting and decrypting your secret files. It uses the public key to encrypt files and the private key to decrypt them.

- **Sops-Nix**: This bridges the gap between Nix and Sops. It allows your Nix configuration to pull in secrets from an encrypted file (_like secrets.yaml_) and use them in your NixOS or home-manager setup.

# Step 5: Setting Up the .sops.yaml File

To simplify things, sops provides a config file, .sops.yaml, where you can specify the public keys of different users and the location of the private keys.

Here’s an example of a **.sops.yaml** configuration:

```yaml
age:
  recipients:
    - age1z0h2m8l5... # your public key here
```

> By setting up this file, you can avoid manually entering long commands and keys in the terminal each time you encrypt or decrypt a file. Now, you can open your secrets.yaml file with a simple command like:

bash

sops secrets.yaml

Sops will automatically decrypt the contents of secrets.yaml using the key from the .sops.yaml configuration file.
Step 6: Telling Nix to Use the Encrypted Secrets

Now that everything is set up, the final step is to configure your Nix setup to use the encrypted secrets.

Here’s how it works: sops-nix integrates into your Nix configuration and looks into the encrypted secrets.yaml file. It retrieves the necessary secrets and makes them available to the rest of your Nix configuration. If a key is present in secrets.yaml, it decrypts it; otherwise, it leaves it untouched.

In essence, sops acts as an intermediary. It helps you manage encrypted secrets in a YAML file (secrets.yaml) and allows sops-nix to use these secrets securely within your Nix configuration.

Here’s an example of how you might configure Nix to use secrets:

nix

{
  config, pkgs, ... }: {
    imports = [ inputs.sops-nix.nixosModules.sops ];

    sops.secrets = {
      mysecret = {
        file = ./secrets.yaml;
        key = "some.secret.key";
      };
    };
  }

This example shows how sops-nix retrieves the secret from secrets.yaml under the key "some.secret.key".
Conclusion

In this guide, we’ve walked through setting up sops-nix step by step. To recap:

    Add sops-nix to your Nix configuration.
    Install the necessary tools: sops and age.
    Generate an Age key pair to handle encryption and decryption.
    Set up .sops.yaml for easier management of keys.
    Configure your NixOS or home-manager setup to retrieve secrets from the encrypted secrets.yaml.

By the end of this process, you’ll have a fully functioning system for securely managing secrets with sops-nix.

Happy hacking!



## Step 2 - Generate an Age Key

Next, you need to generate an age key for encryption, you can use gpg keys but age is considered more safe and secure:

```fish { .my_codeblock hl_Lines="0"}
mkdir -p ~/.config/sops/age

age-keygen -o ~/.config/sops/age/keys.txt

```

## Step 3 - create a .sops.yaml file at the root of your nix config

* Put the age public key which we use to encrypt the files in sops config file .sops.yaml
* Then the relative path to secrets files
* and key groups

```yaml { .my_codeblock hl_Lines="0"}
keys:
  - &user age12zlz6lvcdk6eqaewfylg35w0syh58sm7gh53q5vvn7hd7c6nngyseftjxl
creation_rules:
  - path_regex: secrets/secrets.yaml$
    key_groups:
      age:
      - *user

```

## Step 4 - Create a sops file

```fish { .my_codeblock hl_Lines="0"}
 sops secrets/secrets.yaml

```
It will look like this
```yaml { .my_codeblock hl_Lines="0"}

# Files must always have a string value
example-key: example-value
# Nesting the key results in the creation of directories.
# These directories will be owned by root:keys and have permissions 0751.
myservice:
  my_subdir:
    my_secret: password1

```

* Check the secrets.yaml file

```fish { .my_codeblock hl_Lines="1"}
cat secrets/secrets.yaml

example-key: ENC[AES256_GCM,data:AB8XMyid4P7mXdjj+A==,iv:RRsZC+V+3w22pOi/2TCjBYn/0OYsNGCu5CT1ZBSKGi0=,tag:zT5mlujrSuA6KKxLKL8CMQ==,type:str]
#ENC[AES256_GCM,data:59QWbzCQCP7kLdhyjFOZe503MgegN0kv505PBNHwjp6aYztDHwx2N9+A1Bz6G/vWYo+4LpBo8/s=,iv:89q3ZXgM1wBUg5G29ROor3VXrO3QFGCvfwDoA3+G14M=,tag:hOSnEZ6DKycnF37LCXOjzg==,type:comment]
#ENC[AES256_GCM,data:kUuJCkDE9JT9C+kdNe0CSB3c+gmgE4We1OoX4C1dWeoZCw/o9/09CzjRi9eOBUEL0P1lrt+g6V2uXFVq4n+M8UPGUAbRUr3A,iv:nXJS8wqi+ephoLynm9Nxbqan0V5dBstctqP0WxniSOw=,tag:ALx396Z/IPCwnlqH//Hj3g==,type:comment]
myservice:
    my_subdir:
        my_secret: ENC[AES256_GCM,data:hcRk5ERw60G5,iv:3Ur6iH1Yu0eu2otcEv+hGRF5kTaH6HSlrofJ5JXvewA=,tag:hpECXFnMhGNnAxxzuGW5jg==,type:str]
sops:
    kms: []
    gcp_kms: []
    azure_kv: []
    hc_vault: []
    age:
        - recipient: age12zlz6lvcdk6eqaewfylg35w0syh58sm7gh53q5vvn7hd7c6nngyseftjxl
          enc: |
            -----BEGIN AGE ENCRYPTED FILE-----
            YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0+IFgyNTUxOSB1dFYvSTRHa3IwTVpuZjEz
            SDZZQnc5a0dGVGEzNXZmNEY5NlZDbVgyNVU0Clo3ZC9MRGp4SHhLUTVCeWlOUUxS
            MEtPdW4rUHhjdFB6bFhyUXRQTkRpWjAKLS0tIDVTbWU2V3dJNUZrK1A5U0c5bkc0
            S3VINUJYc3VKcjBZbHVqcGJBSlVPZWcKqPXE01ienWDbTwxo+z4dNAizR3t6uTS+
            KbmSOK1v61Ri0bsM5HItiMP+fE3VCyhqMBmPdcrR92+3oBmiSFnXPA==
            -----END AGE ENCRYPTED FILE-----
        - recipient: age18jtffqax5v0t6ehh4ypaefl4mfhcrhn6ek3p80mhfp9psx6pd35qew2ww3
          enc: |
            -----BEGIN AGE ENCRYPTED FILE-----
            YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0+IFgyNTUxOSBzT3FxcDEzaFRQOVFpNkg2
            Skw4WEIxZzNTWkNBaDRhcUN2ejY4QTAwTERvCkx2clIzT2wyaFJZcjl0RkFXL2p6
            enhqVEZ3ZkNKUU5jTlUxRC9Lb090TzAKLS0tIDBEaG00RFJDZ3ZVVjBGUWJkRHdQ
            YkpudG43eURPVWJUejd3Znk5Z29lWlkK0cIngn2qdmiOE5rHOHxTRcjfZYuY3Ej7
            Yy7nYxMwTdYsm/V6Lp2xm8hvSzBEIFL+JXnSTSwSHnCIfgle5BRbug==
            -----END AGE ENCRYPTED FILE-----
    lastmodified: "2021-11-20T16:21:10Z"
    mac: ENC[AES256_GCM,data:5ieT/yv1GZfZFr+OAZ/DBF+6DJHijRXpjNI2kfBun3KxDkyjiu/OFmAbsoVFY/y6YCT3ofl4Vwa56Veo3iYj4njgxyLpLuD1B6zkMaNXaPywbAhuMho7bDGEJZHrlYOUNLdBqW2ytTuFA095IncXE8CFGr38A2hfjcputdHk4R4=,iv:UcBXWtaquflQFNDphZUqahADkeege5OjUY38pLIcFkU=,tag:yy+HSMm+xtX+vHO78nej5w==,type:str]
    pgp: []
    unencrypted_suffix: _unencrypted
    version: 3.7.1

```
## Step -5
```nix { .my_codeblock hl_Lines="0"}
{
  imports = [ <sops-nix/modules/sops> ];
  # This will add secrets.yml to the nix store
  # You can avoid this by adding a string to the full path instead, i.e.
  # sops.defaultSopsFile = "/root/.sops/secrets/example.yaml";
  sops.defaultSopsFile = ./secrets/example.yaml;
  # This will automatically import SSH keys as age keys
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  # This is using an age key that is expected to already be in the filesystem
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
  # This will generate a new key if the key specified above does not exist
  sops.age.generateKey = true;
  # This is the actual specification of the secrets.
  sops.secrets.example-key = {};
  sops.secrets."myservice/my_subdir/my_secret" = {};
}
```

