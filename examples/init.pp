# Example usage of the nanitor_agent Puppet module.
#
# This will install the Nanitor Agent and run the signup command if not already signed up.
#
# Replace the signup_url with a real one provided by your Nanitor Hub.

class { 'nanitor_agent':
  signup_url => 'https://myinstance.nanitor.net/your-signup-token',
}
