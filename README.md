# README

## Explaination

### Model Link

- Fields:
  - `original_url`: Original URL input from user
  - `original_url_hash`: SHA256 hash of original URL, indexing with unique, we use this value to find the original URL
  - `short_code`: A random short code, it is indexed and unique

- Methods:
  - `.find_or_create_new_link`: receive url string, find it on DB by original_url_hash. If it is not found, create new record. We catch the ActiveRecord::RecordNotUnique exection and retry to make sure 2 same URLs or 2 same short code maybe create at a same time.
  - `#short_url`: it returns the full shorten url

### Routes

- `encode`: Receive url from user input, call the method `find_or_create_new_link` and return shorten url with json format
- `decode`: Receive short code, find it on DB and return original url if it is existing
- `root: links#index`: it is a HTML page to testing, it returns the value only, no handle redirect

## How to run

- Pull this code from respository
- `bundle install` to install dependencies
- `cp .env.example .env` to create .env file and provide your value for them
- `rails db:migrate` to migrate DB
- `rails s` and you can testing the app here

### Unit test
- Define under folder `spec/`
- Run `bundle exec rspec` to run all examples

## Security

- Brute-force: Short codes are at least 6 characters. Apply rate limiting and block IP.
- Spam: Apply rate limiting and block IP.
- XSS: Only valid http/https URLs are accepted. No user input is rendered as HTML.
- SQL Injection: All DB access uses ActiveRecord.

## Scaleable (implement later)

- Use a Load Balancer to handle request
- Using cache system to reduce DB load data from DB, when a request coming to encode the short code, we will find on cache before load from database
- If the data becomes large, we can use sharding DB, example sharding by IDs if we use auto increment ID
- Functionality:
  - We can set `expire_time` to a `link` record and remove it from DB
  - We can add table `users` to manage link of registered users

## Collision

- Check existing URL by original_url_hash and short code before insert to DB.
- Retry if it pass the model validation and save to DB
- Increase short_code length if the number of records becomes large.
