# Submission Setup Instructions
I implemented this challenge in Sinatra, not only because it is lightweight, but you can easily integrate ActiveRecord for the relational database ORM, Rack-based OpenID authentication, and handle HAML frontend templating.  Included is a Bundler Gemfile for easy dependency management.

Clone the git repository 
```sh
$ git clone https://github.com/jdittric/data-engineering.git
$ cd data-engineering/
```

Install necessary gem dependencies
```sh
$ bundle install
```
You may need to use `sudo` for install permissions.  Sinatra will pick up and use thin as the webserver automatically.

Rake migration task
```sh
$ rake db:migrate
```

Start the app
```sh
$ ruby tsv_service.rb
```

Sinatra will start thin on the default listening port (4567).

* Browse to localhost:4567

* Login => upload tab-separated data files => ??? => Profit!


## Caveats
There are several suboptimal implementations in this submission, I will now point these out, since I am ordinarily more careful.

1. *Rack::Session secret* - this should ideally be a much stronger value, and in production set by environment.  Hard-coding this value in source is considered a security risk.

2. *Warden OpenID strategy* - when authenticating, the user's OpenID response is merely checked to see if it succeeded.  Ordinarily this is matched up with a particular row in a User table of known users, by something like the person's unique email address, which is not implemented.

3. *OpenID nonce age* - If you do not have accurate system time, e.g., by synching over ntp with `ntpdate` regularly, you will receive an OpenID auth failure response due to stale nonce time.  This is prone to happen on virtual machines that have been restarted from a suspended state.  The fix is as simple as:

```sh
$ sudo ntpdate pool.ntp.org
```


## Comments
* What a fun little problem, thanks LivingSocial.  I honestly have not used normalized, relational databases for some time in favor of NoSQL, so it was a nice refresher with sqlite3.

* Please excuse my mixing of old (`{:key => value}`) and new (`{key: value}`) Hash syntax, it's a work in progress.

* This app demo is dedicated to Jim Weirich; I'm reminded that rake is such a valuable tool, so thanks for a lifetime of giving to the Ruby dev community.

---

# Challenge for Software Engineer - Big Data 
To better assess a candidates development skills, we would like to provide the following challenge.  You have as much time as you'd like (though we ask that you not spend more than a few hours).

There are three jobs that both use this challenge:

1. Senior Software Engineer: If you are applying to this position, the email address you should use for submission is [dev.challenges@livingsocial.com](dev.challenges@livingsocial.com).  You must use either Ruby/Ruby on Rails or Scala/Play2.0.
1. Senior Software Engineer, Big Data (and/or Data Scientist): If you are applying to this position, the email address you should use for submission is [data.challenge@livingsocial.com](mailto:data.challenge@livingsocial.com).  You may use any programming language or framework you'd like.

Feel free to email the appropriate address above if you have any questions.

## Submission Instructions
1. First, fork this project on github.  You will need to create an account if you don't already have one.
1. Next, complete the project as described below within your fork.
1. Finally, push all of your changes to your fork on github and submit a pull request.  You should also email the appropriate address listed in the first section and your recruiter to let them know you have submitted a solution.  Make sure to include your github username in your email (so we can match people with pull requests).

## Alternate Submission Instructions (if you don't want to publicize completing the challenge)
1. Clone the repository
1. Next, complete your project as described below within your local repository
1. Email a patch file to the appropriate address listed above ([data.challenge@livingsocial.com](mailto:data.challenge@livingsocial.com) if you are applying for the Big Data position, [dev.challenges@livingsocial.com](dev.challenges@livingsocial.com) if you are applying for the general Senior Software Engineer or Associate Developer position).

## Project Description
Imagine that LivingSocial has just acquired a new company.  Unfortunately, the company has never stored their data in a database and instead uses a plain text file.  We need to create a way for the new subsidiary to import their data into a database.  Your task is to create a web interface that accepts file uploads, normalizes the data, and then stores it in a relational database.

Here's what your web-based application must do:

1. Your app must accept (via a form) a tab delimited file with the following columns: purchaser name, item description, item price, purchase count, merchant address, and merchant name.  You can assume the columns will always be in that order, that there will always be data in each column, and that there will always be a header line.  An example input file named example_input.tab is included in this repo.
1. Your app must parse the given file, normalize the data, and store the information in a relational database.
1. After upload, your application should display the total amount gross revenue represented by the uploaded file.

Your application does not need to:

1. handle authentication or authorization (bonus points if it does, extra bonus points if authentication is via OpenID)
1. be written with any particular language or framework
1. be aesthetically pleasing

Your application should be easy to set up and should run on either Linux or Mac OS X.  It should not require any for-pay software.

## Evaluation
Evaluation of your submission will be based on the following criteria. Additionally, reviewers will attempt to assess your familiarity with standard libraries. If your code submission is in Ruby, reviewers will attempt to assess your experience with object-oriented programming based on how you've structured your submission.

1. Did your application fulfill the basic requirements?
1. Did you document the method for setting up and running your application?
1. Did you follow the instructions for submission?
