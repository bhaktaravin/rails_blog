class RemoveFlightTables < ActiveRecord::Migration[8.1]
  def change
    # Remove unrelated flight tables from blog database
    drop_table :FlightSegment, if_exists: true
    drop_table :FlightResult, if_exists: true
    drop_table :Search, if_exists: true
    drop_table :FlightSearch, if_exists: true
    drop_table :Route, if_exists: true
  end
end
