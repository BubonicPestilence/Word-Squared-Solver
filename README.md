# Word Squared Solver
A simple ruby application that solves your http://wordsquared.com/ :)

## Getting started

### Setup settings.rb

1. Edit settings.example.rb, put in your username and password.
2. Tune `$fails_before_swap_tiles`, e.g. if you have stars < 100, set it to 1k+ else set it to 3

### Setup ruby

```bash
$> gem install httparty nokogiri
```

### Run it

```bash
$> ruby run.rb
```
