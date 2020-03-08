# Contributing

## Development

### Working locally

You can deploy an instance of this project on your local machine, as long as you have
[Vagrant](https://www.vagrantup.com/) installed.

You can quickly deploy to your local environment by running `bundle exec kitchen converge`.

### Working with Digital Ocean

To deploy on Digital Ocean, simply [create an access token](https://cloud.digitalocean.com/account/api/tokens/new),
[upload an SSH key](https://cloud.digitalocean.com/account/security), and follow the steps below.

```shell
export DIGITALOCEAN_ACCESS_TOKEN='<PASTE YOUR ACCESS TOKEN HERE>'
export DIGITALOCEAN_SSH_KEY_IDS='<PASTE THE ID OF YOUR SSH KEY HERE>' # See below if you don't know this.
export DIGITALOCEAN_REGION='lon1' # Set the Digital Ocean region you wish to deploy to.
```

If you don't know your SSH Key ID, you can find out by querying the Digital Ocean API:

```shell
DIGITALOCEAN_ACCESS_TOKEN='<PASTE YOUR ACCESS TOKEN HERE>'
DIGITALOCEAN_SSH_KEY='<NAME OF YOUR SSH KEY IN DIGITAL OCEAN>'
DIGITALOCEAN_SSH_KEY_IDS=$(curl -s -X GET -H "Content-Type: application/json" -H "Authorization: Bearer ${DIGITALOCEAN_ACCESS_TOKEN}"  "https://api.digitalocean.com/v2/account/keys" | jq --arg key ${DIGITALOCEAN_SSH_KEY} '.ssh_keys | .[] | select(.name == $key) | .id')
echo "Your token ID is '${DIGITALOCEAN_SSH_KEY_IDS}'"
export DIGITALOCEAN_ACCESS_TOKEN
export DIGITALOCEAN_SSH_KEY_IDS
```

You can quickly deploy to Digital Ocean by running `bundle exec kitchen converge digitalocean`.
