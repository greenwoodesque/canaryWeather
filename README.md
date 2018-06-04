# canaryWeather

The Deservedly Unnamed Weather Forecasting App

What we expect: After granting locations permission, an 8-day forecast for your current location (the most I could find for free) appears. Refresh or find other locations via the nav bar buttons. A toolbar will appear at the bottom once you’ve added at least one other location, providing the option to switch among your saved places. If you have past days’ forecasts saved for a given location, a “History” button will also appear in the toolbar. Tapping any summary cell will reveal the full weather report for that day/place. 

The design: Forecast day collections are handled by one view controller configured for location and time (current/past). Its state and non-ui-specific behaviors (interacting with core data, the network etc) are bundled to something like a view model. Another class encapsulates the collection view. There are three other view controllers, all very small and without associated view models: the forecast detail, location search, and saved location selection. The Core Data interactions could be optimized and made scalable without too much trouble. For now, I assume small data sets. 

Lastly, despite the evidence, I want to mention that I’m not really totally lacking in aesthetic sense. 
