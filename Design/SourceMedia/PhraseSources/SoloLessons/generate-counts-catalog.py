"""Generate the Swift timeline literals from reviewed source-time annotations.

This authoring utility and its JSON stay outside the application bundle.
Run from any directory with Python 3; it does not build or launch the app.
"""
import json
import re
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
CATALOG = ROOT / "Teto/Domain/DancePhraseCatalog.swift"
BEGIN = "    // BEGIN GENERATED FILM TIMELINES"
END = "    // END GENERATED FILM TIMELINES"

def generated():
    data = json.loads((HERE / "counts-timelines.json").read_text())
    films = data["films"]
    out = [BEGIN, "    // Source: Design/SourceMedia/PhraseSources/SoloLessons/counts-timelines.json",
           "    static let timelines: [String: PhraseFilmTimeline] = ["]
    for index, phrase_id in enumerate(films):
        out.append(f'        "{phrase_id}": filmTimeline{index}(),')
    out.extend(["    ]", ""])
    for index, (phrase_id, film) in enumerate(films.items()):
        out.extend([f"    private static func filmTimeline{index}() -> PhraseFilmTimeline {{",
                    "        PhraseFilmTimeline(",
                    f'            assetName: "{film["assetName"]}", duration: {film["duration"]}, cues: ['])
        previous = 0
        for cue in film["cues"]:
            assert cue["start"] == previous and cue["end"] > previous
            assert cue["end"] <= film["duration"]
            assert cue["text"].isascii() and 0 < len(cue["text"]) <= 48
            assert not re.search(r"\b(demo|demonstration|showcase|sample|mock|mockup|prototype|exhibition|preview|presentation|display)\b", cue["text"], re.I)
            previous = cue["end"]
            text = json.dumps(cue["text"])
            action = "true" if cue["isAction"] else "false"
            out.append(f'                PhraseTimedCue(start: {cue["start"]}, end: {cue["end"]}, text: {text}, isAction: {action}),')
        assert previous == film["duration"]
        out.extend(["            ])", "    }", ""])
    out.append(END)
    return "\n".join(out)

if __name__ == "__main__":
    source = CATALOG.read_text()
    assert source.count(BEGIN) == source.count(END) == 1
    start, finish = source.index(BEGIN), source.index(END) + len(END)
    CATALOG.write_text(source[:start] + generated() + source[finish:])
    print("Updated seven film timelines; no application code executed.")
