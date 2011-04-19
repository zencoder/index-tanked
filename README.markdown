Index Tanked
============

Index Tanked helps you index and search your data on IndexTank. Index Tanked works with any Ruby class but has additional helpful default behavior when used with Active Record.

***

Install
--------

If you're using Bundler toss a `gem 'index-tanked'` in your GEMFILE. Otherwise `gem install 'index-tanked'`

Example
-------

ActiveRecord Example
--------------------

Configuration
-------------
You can optionally configure some things in the `IndexTanked::Configuration` class. e.g.

    IndexTanked::Configuration.index = 'your_index_name'

#### url
The private IndexTank url that will be used if you don't specify one when you define your index.

#### index
The index that will be used if you don't specify one when you define your index.

#### search_availability
Whether or not searching is enabled. This can be a boolean or a proc. This value can also be queried by calling `IndexTanked::Configuration.search_available?`. If a search is attempted while this is false a `SearchingDisabledError` will be raised.

#### index_availability
Whether or not indexing is enabled. This can be a boolean or a proc. This value can also be queried by calling `IndexTanked::Configuration.index_available?`. If you attempt to add to or delete from the index while this is false an `IndexingDisabledError` will be raised and your index or delete fallback will be triggered if configured.

#### timeout
Timeout in seconds. If this is configured then when you attempt to add or delete from your index a `TimeoutExceededError` will be raised when the configured time has elapsed. This will trigger your add to index or delete fallback if configured.

### Fallback methods
These let you define how to handle if if something goes wrong when communicating with IndexTank. For example if you fail to add a record to IndexTank due to a temporary network issue you may want to try again later in a background task. e.g.

    IndexTanked::Configuration.add_to_index_fallback do |information_from_failed_attempt|
        information_from_failed_attempt[:class].send_later.add_to_index_tank_without_fallback(information_from_failed_attempt[:doc_id], information_from_failed_attempt[:data])
    end

Note that if you are adding your failures to a worker queue like Delayed Job that has it's own method for retrying failures it is important that you use the _without_fallback version of the method you are backgrounding so that each failures in the background queue don't result in new jobs being added to the queue.

#### add_to_index_fallback
The block or proc that is executed when an exception happens while attempting to add a record to IndexTank. The hash passed in contains the `:class`, `:data`, `:doc_id` and the `:error` that caused the original attempt to fail.

#### delete_from_index_fallback
The block or proc that is executed when an exception happens while attempting to remove a record from to IndexTank. The hash passed in contains the `:class`, `:doc_id` and the `:error` that caused the original attempt to fail.

#### missing_activerecord_ids_handler
This block or proc lets you handle the situation where records that are no longer in your database have been returned in a search from IndexTank. You may, for example, take this opportunity to remove them from the index. The block is passed two arguments, the `model_name` and the `ids`.
