TVTropes-correlation
====================
Look at two works and determine how similar they are in terms of the tropes they use.

Live at http://tvtropes-correlation.herokuapp.com/

To start, follow the new movie link from the home page.
Input a TVTropes URL for a movie (or other media).

The movie and its trope set are then scraped from TVTropes.org.

Each movie's page lists up to 5 movies with the most similar trope sets.

The similarity metric for two works is:
(number of matching trope) / (number of possible matches)