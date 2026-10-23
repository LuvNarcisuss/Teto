# Phrases design

Locked behavior for the Phrases tab. The implementation plan is `docs/superpowers/plans/2026-10-22-phrases.md`.

## Place

Phrases is a bottom-tab page beside Live, Voice, Chats, and Me. Order: Live, Phrases, Voice, Chats, Me. Shorts stays inside Live. The tab completes reading, counting, learning, keeping, and rewriting a phrase. It does not play a video and does not open a voice room.

## Phrase

A phrase has a title, one style, one tempo, one to four eights, and an author. Each eight has eight counts. Each count is one non-empty English line of up to 48 characters. The title is non-empty English of up to 40 characters. `hold` is a valid count. An empty line, a Chinese character, or a line of only symbols cannot be saved.

Styles: Hip-hop, K-pop, Jazz, Freestyle, Ballet, House, Contemporary.

Tempo is the click speed:

| Word | Beats per minute | Seconds per beat |
| --- | --- | --- |
| Slow | 60 | 1 |
| Steady | 80 | 0.75 |
| Quick | 100 | 0.6 |

Steady and Quick are fixed so the click has one speed. Slow is one beat per second.

## Two faces

The closed card shows the author portrait, title, first count, style, tempo, eight count, learned marks, and `From` plus the parent title when the phrase is a branch. Tap opens the phrase. Tap the portrait opens that dancer's existing profile. Long press on someone else's card offers Report phrase and Block dancer. Long press on your own card offers Edit phrase and Delete phrase.

The open page shows the author, style, tempo, title, parent line, the current eight, and the eight counts. The current count is emphasized while the click plays.

## Counting

`This eight` is the primary control. It plays one preparation of 5, 6, 7, 8, then repeats counts 1 through 8 of the eight on screen. The preparation plays only when the click starts. After 8, the next beat is 1 of the same eight.

`From the start` plays one preparation, then every eight from the first to the last, with no preparation between eights. It stops on the last count and stays on the last eight.

Leaving the page, locking the phone, or starting another phrase stops the click and allows the screen to sleep. Beat 1 is a stronger click. The highlighted count still advances if the click cannot be heard. The page then says `The click could not start.`

`Larger type` fills the page with the current eight and leaves the click, stop, and eight switch. `Smaller type` returns the other controls.

## Learning, keeping, branching

`Learned` toggles the eight on screen. One mark per eight. All marks lit shows `Learned` beside the title. Marks belong to this device.

`Keep` places the phrase in the Kept group at the top of Phrases. Tapping again removes it from Kept and leaves the phrase in the list.

`Branch` is shown on someone else's phrase. It copies every count. Saving requires at least one eight to differ. The new phrase uses your name, stores `From` plus the parent title, and records which eights changed, such as `Changed eight 3`. It appears under the parent and in your phrases. Your own phrase offers `Edit phrase` instead of `Branch`.

Editing your phrase can change the title, style, tempo, and counts. Saving a branch that matches its parent asks you to change a count or leave the phrase as it is. Changing an eight clears the learned mark for that eight.

`Delete phrase` asks first. The phrase, its keep, and its learned marks leave this device. Phrases branched from it keep their own counts and the parent title. The parent line stays and does not open when the parent is gone.

Built-in phrases can be kept, learned, branched, and reported. They cannot be edited or deleted.

## List order

Kept, newest keep first. Then your phrases, newest first, skipping any already in Kept. Then the built-in phrases in catalog order, skipping any already in Kept. A hidden phrase is absent from every group.

## Built-in phrases

These seven phrases ship in the app. They are catalog text, not a live post. Authors use the existing chat dancer ids.

| id | Title | Style | Tempo | Author id | Author |
| --- | --- | --- | --- | --- | --- |
| phrase-weight-shift | Weight shift | Hip-hop | Slow | maya | Maya Chen |
| phrase-point-and-hit | Point and hit | K-pop | Quick | maya | Maya Chen |
| phrase-reach-and-melt | Reach and melt | Contemporary | Slow | zoe | Zoe Park |
| phrase-loose-groove | Loose groove | House | Steady | leo | Leo Brooks |
| phrase-shoulder-sway | Shoulder sway | Freestyle | Steady | noah | Noah Rivera |
| phrase-long-arms | Long arms | Ballet | Slow | aria | Aria Wilson |
| phrase-step-touch | Step touch | Jazz | Quick | finn | Finn Taylor |

Weight shift, eight 1: step right / cross left over / sit into the right hip / hold / step left / cross right over / sit into the left hip / hold.

Weight shift, eight 2: rock the chest forward / rock the chest back / keep the knees soft / hold / step right / together / step left / together.

Point and hit, eight 1: step right / point left / bring the left knee in / hit the right hand / step left / point right / bring the right knee in / hit the left hand.

Point and hit, eight 2: look right / look front / small jump / land soft / clap / clap / freeze / hold.

Reach and melt, eight 1: reach the right arm up / let the ribs follow / melt the chest down / hang the head / roll up through the spine / find the eyes forward / soften the knees / hold.

Reach and melt, eight 2: step back on the right / reach both arms wide / gather the arms in / fold forward / press through the feet / stand tall / lower the arms / hold.

Loose groove, eight 1: step right / step left / loose the right heel / loose the left heel / shift the weight right / shift the weight left / keep the chest quiet / hold.

Loose groove, eight 2: tap right / step right / tap left / step left / ride the bounce / ride the bounce / smaller bounce / hold.

Shoulder sway, eight 1: sway right / sway left / drop the right shoulder / drop the left shoulder / circle the chest / circle the chest / find center / hold.

Shoulder sway, eight 2: step touch right / step touch left / roll the right shoulder / roll the left shoulder / walk forward / walk forward / stay / hold.

Long arms, eight 1: stand in first / open the arms / grow tall through the head / hold / bend the knees / keep the heels down / stretch the knees / close the arms.

Long arms, eight 2: tendu the right foot / point the toe / close to first / hold / tendu the left foot / point the toe / close to first / arms rest.

Step touch, eight 1: step right / touch left / step left / touch right / kick the right foot / step right / kick the left foot / step left.

Step touch, eight 2: clap / clap / step right / together / step left / together / look right / hold.

## Share, report, block

Share uses the existing in-app sheet. Choosing a followed friend saves this pending message in that chat on this device:

`Practice this phrase: {title}. Address: teto://phrase/{id}`

The confirmation is `Saved in your chat with {name}. It stays on this device.` Share link copies `teto://phrase/{id}` and says `Link copied. This address stays inside Teto and is not a public web page.` No message service is claimed. The address is not opened as a web page.

Report phrase uses the existing report form and stores the report on this device. The phrase leaves Phrases until the report is removed in Settings. The Reported card shows the title, author, and first count. It does not click or play.

Block dancer asks first, then uses the existing block for that author id. Phrases by that id hide. Videos, rooms, and chats hide when they already use that same id. Ids are not matched by name. You cannot report or block your own phrase.

## Device boundary

New phrases, keeps, learned marks, reports, and chat copies stay in the local library. Another phone does not receive them. The library schema version stays 1. The phrase book is an optional field so an older library still opens.
