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

