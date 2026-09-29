# yeet-trip-location

Andaman or Goa? A one-page comparison for our winter trip: travel logistics, diving courses, hotels, activities, a per-person cost estimate, and polls.

- Everyone picks their name first (Adeev's needs a password).
- Polls: diving course, Havelock hotel, Goa hotel, and the final Andaman vs Goa vote. You can change your vote any time.
- Votes are saved in Supabase (the same project as yeet-trip-dates). Nobody can read the votes table directly; the page only calls the functions in `supabase/votes.sql`. Results come back only with Adeev's password, checked on the server.

The whole site is `index.html`, hosted on GitHub Pages. Prices are rough and change with dates.
