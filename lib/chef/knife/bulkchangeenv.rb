#
# Author:: Jon Cowie (<jonlives@gmail.com>)
# Copyright:: Copyright (c) 2011 Jon Cowie
# License:: GPL


require 'chef/knife'

module KnifeBulkChangeEnv
  class NodeBulkChangeEnvironment < Chef::Knife

    deps do
      require 'chef/search/query'
      require 'chef/knife/search'
    end

    banner "knife node bulk_change_environment OLDENVIRONMENT NEWENVIRONMENT [QUERY]"

    def run
      unless @old_env = name_args[0]
        ui.error "You need to specify a Environment to update from"
        exit 1
      end

      unless @new_env = name_args[1]
        ui.error "You need to specify an environment to update to"
        exit 1
      end

      unless @query_string = name_args[2]
        ui.msg "No additional search query given"
      else
        ui.msg "Using additional search query: #{@query_string}"
      end

      puts "Checking for an environment called #{@old_env} to update from..."

      searcher = Chef::Search::Query.new
      result = searcher.search(:environment, "name:#{@old_env}")

      env = result.first.first
      if env.nil?
        puts "Could not find an environment named #{@old_env}. Can't update nodes in a non-existant environment!"
        exit 1
      else
        puts "Found!\n"
      end


      puts "Checking for an environment called #{@new_env} to update to..."

      searcher = Chef::Search::Query.new
      result = searcher.search(:environment, "name:#{@new_env}")

      env = result.first.first
      if env.nil?
        puts "Could not find an environment named #{@new_env}. Please create it before trying to put nodes in it!"
        exit 1
      else
        puts "Found!\n"
      end

      q_nodes = Chef::Search::Query.new
      node_query = "chef_environment:#{@old_env}"
      if @query_string
        node_query += " AND (#{@query_string})"
      end
      query_nodes = URI.escape(node_query,
                         Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))

      result_items = []
      result_count = 0

      ui.msg("\nFinding all nodes in environment #{@old_env}#{" matching '" + @query_string + "'" if @query_string} and moving them to environment #{@new_env}...\n")

      begin
        q_nodes.search('node', query_nodes) do |node_item|

          node_item.chef_environment(@new_env)
          node_item.save
          formatted_item_node = format_for_display(node_item)
          if formatted_item_node.respond_to?(:has_key?) && !formatted_item_node.has_key?('id')
            formatted_item_node.normal['id'] = node_item.has_key?('id') ? node_item['id'] : node_item.name
          end
          ui.msg("Updated #{formatted_item_node.name}...")
          result_items << formatted_item_node
          result_count += 1
        end
      rescue Net::HTTPServerException => e
        msg = Chef::JSONCompat.from_json(e.response.body)["error"].first
        ui.error("knife preflight failed: #{msg}")
        exit 1
      end

      if ui.interchange?
        output({:results => result_count, :rows => result_items})
      else
        ui.msg "#{result_count} Nodes updated"
      end

    end
  end
end