signUpForm = function(){
  $("#home-box").empty()
  $("#home-box").html(`<div id="signupform">
    <form action= "/users" method = "post">
      <input type = "text" name = "username" placeholder="username">
      <input type = "text" name = "first_name" placeholder="first name">
      <input type = "text" name = "last_name" placeholder="last_name">
      <input type = "text" name = "email" placeholder="email">
      <input type = "password" name = "password" placeholder="password">
      <input type = "password" name = "password_confirm" placeholder="confirm password">
      <input type = "submit" value = "Sign up">
    </form>
  </div>`)
}
