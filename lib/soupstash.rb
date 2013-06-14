# This differs from DCSS in that it represents logic for the Soup
# Stash application (which could do with a better name) whereas DCSS
# is strictly for reasoning with Crawl data.

require 'soupstash/ingestlogfile/transformer'
# XXX Bleurgh.
$: << Dir.pwd + '/vendor/dcss_henzell/src'
require 'helper'
require 'henzell/sources'

module SoupStash
  def self.ttyrecs_for(game)
    Dir.chdir('./vendor/dcss_henzell') {
      Henzell::Sources.instance.ttyrecs_for(
        SoupStash::IngestLogfile::Transformer.game_hash_to_logfile_hash(
          game.instance_values['attributes']
        )
      )
    }
  end
end
