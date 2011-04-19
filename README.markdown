Index Tanked
============

Index Tanked helps you index and search your data on IndexTank. Index Tanked works with any Ruby class but has additional helpful default behavior when used with Active Record.

***

Install
--------

If you're using Bundler toss a `gem 'index-tanked'` in your GEMFILE. Otherwise `gem install 'index-tanked'`

Example
-------

    require 'rubygems'
    require 'index-tanked'

    class Dog
      include IndexTanked

      attr_accessor :breed, :flea_count, :name, :behavior_score, :description

      index_tank :index => 'dogs', :url => 'http://example@indextank.com' do
        doc_id, :doc_id
        field :breed
        field :behavior_score, :text => nil
        field :fleas, :flea_count, :text => lambda { |dog| 'infested' if dog.flea_count > 5 }
        field :name
        text :description
        var 0, 15
      end

      def doc_id
        ...
      end
    end


### What did we just do?

First thing's first. Include IndexTanked in your class. Next up is the index_tank block where we determine what we're going to index. You can pass in the index name and url here, alternatively if you have added a url and index to the configuration you can leave it off here and the configured ones will be used.

 The first thing we define is the doc_id. The doc_id is the ID of your record in IndexTank and you need to be able to generate a unique one for each instance that you'll be indexing. If you're using ActiveRecord you can skip this as it's defined by default, if you're using anything else you'll need to come come up with your own. You could base it on the url that points to the document, or the id used by your data store, etc.

Next up are the fields. When you do a search in IndexTank you can specify which field you are searching like this: `breed:pug`. If you don't specify a field you end up searching a special field called text. By default when you add a field in IndexTanked the value of that field *also* goes into the text field.

Sometimes you don't want that to occur, for instance, assuming that :behavior_score, above, is just a number, it may not make sense to have its value go into the text field since you may have multiple numerical fields and it may not make sense for a search of '5' to return dogs with 5 fleas and dogs with a behavior score of 5. If that is the case then `:text => nil` will prevent the field's value from being added to the text field.

The field method takes three arguments. The first argument is what the field should be called in IndexTank. The second argument is the optional method to retrieve the value for the field. If it's not provided then it is assumed that the first argument is also the method to retrieve its value. This can be a symbol (the name of the method to call), a Proc which will be executed, or just a String / Integer etc which will then be indexed identically for all instances.

If you want something other than the value of the field to be added to the text field you can specify it with :text, in the example above any dog with more than 5 fleas will have the word 'infested' in their text field, allowing them to be found by searching for 'infested'.

The text method takes one argument, which is a value to be *added* to the text field. This does not replace the text field, just adds to it. As above this may be a proc, symbol etc.

The var method adds a variable. See the IndexTank documentation for why you might want to do such a thing.

### What can we do now that we've done that?

#### Instance methods
*add_to_index_tank* Add your instance to your index on IndexTank.

#### Class Methods
*add_to_index_tank(doc_id, data, fallback)* This method is called internally by the instance method, the third argument is optional and defaults to true, it determines whether or not your add_to_index_fallback will be called.

*add_to_index_tank_without_fallback(doc_id, data)* Calls the above, passing false to fallback.

*delete_from_index_tank(doc_id, fallback)* Removes the document with the doc_id passed as it's first argument from the index. The second argument is optional and defaults to true, it determines whether or not your delete_from_index_fallback will be called.

*delete_from_index_tank_without_fallback(doc_id)* Calls the above, passing false to fallback.

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
