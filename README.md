# Phoenix API Base

**Quickly get develop a traditional User CRUD API**

A set of contexts, controllers, and helpers to get up to speed fast. Incluedes:

* User JWT token auth via [Guardian](https://github.com/ueberauth/guardian)
* Facebook auth via [Facebook.ex](https://github.com/mweibel/facebook.ex)
* JSON API formatting of responses via [JaSerializer](https://github.com/vt-elixir/ja_serializer)
* Password reset, with email confirmation
* More to come

## Get Started

1. Clone this repository
*Change `project-name` to your projects name.*
```
git clone https://github.com/paulruescher/phoenix-base.git <your-project-name>
cd <project-name>
```

2. Delete git history (optional)
```
rm -r .git
```

3. Get dependencies
```
mix deps.get
```

4. Setup database
```
mix ecto.create && mix ecto.migrate
```

## Rationale

There's usually a bunch of repetitive tasks invovled with setting up a Phoenix app. Setting up account contexts, an auth system, etc. This is an attempt to reduce that overhead when getting started on a JSON API based Phoenix app.

## Architecture Decisions

Below are some architecture notes that are subject to change. They're here to help you understand the approaches I took.

### Auth

There is one SessionController action for creating a session (note: this might change in the future to something more aptly named, like TokenController). The expectation is that this action passes its params to App.Accounts.authenticate_user, which decides what to do.

Based on the params, certain things will happen. As of now, there are two sceniarios:

1. An existing user signs in with a valid email/password combo, or

2. A facebook code is used to get an access_token, which is used to retreive the email for that access_token. If a user with that email does not exist, then it is created.
