-----------------------------------------
Paul Ruescher's notes for October 1, 2017
-----------------------------------------

* add password reset

### Password Reset
* POST to /password/forgot
  * find user by email
  * create reset token, add to user
  * send email with reset token
* POST to /password/reset
  * find user by reset token
  * update user with new password, set reset token to `nil`

-----------------------------------------
Paul Ruescher's notes for October 3, 2017
-----------------------------------------

### FB Auth

* Send user to /dialog/oauth
* User accepts
* Gets redirected back to /redirect_url
* Something sends that code to the server
* That code gets exchanged for an access_token
  * Success
    * Request email
      * Success
        * Create account
        * Sign in account :)
      * Error
        * Freak out
  * Error
    * Freak out

-----------------------------------------
Paul Ruescher's notes for October 31, 2017
-----------------------------------------

* need to start documenting description, useage, @spec
* will need to update Facebook auth when a new version of facebook.ex comes out
