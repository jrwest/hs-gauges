* Move gauges files in .gauges dir 
* Refactor code that deals with directory and files into some sort of util module
* Need some sort of command structure but need to implement a few more first
* Commands and Such 
  * List history for single gauge (by name) using today, yesterday and recent days fields -- also check out the traffic end point for this
  * List history for single gauge by hour using recent hours
  * List history for single gauge by month using recent months
  * Change gauge name
  * List content, referrers, search terms, locations by date per gauge
    * with paging (see older, newer links
  * List browser resolutions, technology (browsers & platforms), search engines by date per gauge
* Integrate Spark lines 
* Cache some of this data and roll it up 
