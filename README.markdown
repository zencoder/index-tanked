Index Tanked
============

Index Tanked helps you index and search your data on IndexTank. Index Tanked works with any Ruby class but has additional helpful default behavior when used with Active Record.

***

Install
--------

If you're using Bundler toss a `gem 'index-tanked'` in your GEMFILE. Otherwise `gem install 'index-tanked'`

Configuration
-------------
You can optionally configure some things in the `IndexTanked::Configuration` class. e.g.
  `IndexTanked::Configuration.index = 'your_index_name'`

### url
The private IndexTank url that will be used if you don't specify one when you define your index.

### index
The index that will be used if you don't specify one when you define your index.

### search_availability
Whether or not searching is enabled. This can be a boolean or a proc. It may occasionally be useful to disable search in your application. This value can also be queried by calling `IndexTanked::Configuartion.search_available?`. If a search is attempted while this is false a `SearchingDisabledError` will be raised.
