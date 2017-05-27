TLS handshake fails checker for Sendmail
========================================

# Description
This script when run detects TLS handshake fails in the preset mail log file
and sends a notification via e-mail of such occurences. It also checks if the 
domain that is failing is alredy known via Sendmail's access file, or if it has
past ocurrences. This is useful if you still need to enable normal mail 
transfer even with domains with misconfigured TLS, you can then simply add 
another exception to Sendmail's access file. It can be called from a cron-ish 
system of your liking.

# Requirements
No additional requirements.
