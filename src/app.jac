########################  IMPORTS  ########################
import from byllm.lib { Model }
import from datetime  { date, timedelta, datetime }
import from time { time }
import from datetime  { date, timedelta, datetime }
import from time { time }
# cl embed_text(str) from __main__;  # For Python embedding bridge

########################  GLOBAL MODELS  ########################
glob llm = Model(model_name="gpt-4o", temperature = 0.7); 

########################  UTILITY FUNCTIONS  ########################
def get_dates(range_option: str) -> tuple {
    today = date.today();
    if range_option == "last7"   { start = today - timedelta(days=7); }
    elif range_option == "last30"{ start = today - timedelta(days=30); }
    else                         { start = today - timedelta(days=7); }
    return (start.strftime("%m/%d/%Y"), today.strftime("%m/%d/%Y"));
}

def embed(text: str) -> list { return embed_text(text); }
def cos_sim(a: list, b: list) -> float {
    dot = 0.0; norm_a = 0.0; norm_b = 0.0;
    for i in range(len(a)) { dot += a[i]*b[i]; norm_a += a[i]*a[i]; norm_b += b[i]*b[i]; }
    return dot / (sqrt(norm_a) * sqrt(norm_b)) if (norm_a > 0 and norm_b > 0) else 0.0;
}

########################  GRAPH SCHEMA  ########################
node root { has user: User = null; }

node User { has created: float = __jac__.time_now(); }

node Journal {
    has note: str,
        ts: float,
        embedding: list = [];
}

node Mood {
    has value: int,   # 1-10
        ts: float;
}

node Trigger {
    has tag: str,
        strength: float = 1.0;
}

node Suggestion {
    has text: str,
        used: bool = False;
}

# Edges
edge Dated      { has date: str; }
edge influences { has weight: float = 1.0; }
edge suggests   { has score: float = 1.0; }
edge similar_to { has cos_sim: float; }

########################  INITIALIZATION  ########################
walker init {
    can start with `root entry {
        if not root.user {
            root.user = User();
            root ++> root.user;
            print("New user initialized.");
        } else {
            print("User loaded.");
        }
    }
}

########################  INGESTION (Restaurant Feedback Pattern: Specialized Walker)  ########################
walker add_journal {
    has text: str;
    has similarity_threshold: float = 0.7;
    has max_links: int = 3;

    can start with `root entry {
        user = root.user;
        if not user {
            report {"error": "User not initialized. Run 'init' first."};
            return;
        }

        # Embed and store journal
        vec = embed(self.text);
        now = time();
        today_str = date.fromtimestamp(now).strftime("%m/%d/%Y");
        j = Journal(note=self.text, ts=now, embedding=vec);
        user ++[Dated(date=today_str)]++> j;

        # Link to similar past journals
        links = 0;
        journals = [user --> Journal];
        for old in journals {
            if links >= self.max_links { break; }
            sim = cos_sim(vec, old.embedding);
            if sim >= self.similarity_threshold {
                j ++[similar_to(cos_sim=sim)]++> old;
                links += 1;
            }
        }

        # 🔥 REPLACES KEYWORD TRIGGERS: LLM-Powered Trigger Extraction
        discovered_triggers = extract_triggers(self.text);
        for trigger_phrase in discovered_triggers {
            existing = [user --> Trigger];
            existing_trigger = null;
            for t in existing {
                if t.tag == trigger_phrase {
                    existing_trigger = t;
                    break;
                }
            }
            t = existing_trigger if existing_trigger else Trigger(tag=trigger_phrase, strength=0.8);
            if not existing_trigger { user ++> t; }
            t ++[influences(weight=0.8)]++> j;
        }

        # Generate empathetic reply
        reply = empathize(self.text);
        sug = Suggestion(text=reply);
        user ++> sug;
        j ++[suggests(score=1.0)]++> sug;

        report {
            "status": "success",
            "journal_id": j.id,
            "suggestion": reply,
            "triggers_found": discovered_triggers,
            "similar_links": links
        };
    }
}

# LLM for trigger extraction
"""From this journal entry, extract all specific emotional triggers.
Return as a list of 1-3 word phrases.
Example: ["work deadline", "family argument", "exercise", "rainy weather"]
Do NOT include generic terms like "life" or "day".
Text: {journal_text}"""
def extract_triggers(journal_text: str) -> list by llm(method="Simple");

# Empathetic reply
"""Respond to this personal journal entry with deep empathy, validation, and gentle encouragement.
Keep it under 3 sentences. Sound human, not robotic.
Entry: {text}"""
def empathize(text: str) -> str by llm() ;

########################  LOG MOOD  ########################
walker log_mood {
    has value: int;          # 1-10
    has triggers: list[str] = [];

    can start with `root entry {
        user = root.user;
        if not user {
            report {"error": "User not initialized."};
            return;
        }

        now = __jac__.time_now();
        today_str = date.fromtimestamp(now).strftime("%m/%d/%Y");
        m = Mood(value=self.value, ts=now);
        user ++[Dated(date=today_str)]++> m;

        # Link to previous mood
        prev_moods = [user --> Mood];
        if prev_moods { prev_moods[-1] ++> m; }

        # Link triggers
        for tag in self.triggers {
            existing = [user --> Trigger];
            existing_trigger = null;
            for t in existing {
                if t.tag == tag {
                    existing_trigger = t;
                    break;
                }
            }
            t = existing_trigger if existing_trigger else Trigger(tag=tag);
            if not existing_trigger { user ++> t; }
            t ++[influences(weight=1.0)]++> m;
        }

        report {"status": "mood_logged", "mood_id": m.id};
    }
}

########################  TOOLS FOR INSIGHTS ########################
def filter_moods(start_date_str: str, end_date_str: str) -> dict {
    start = datetime.strptime(start_date_str, "%m/%d/%Y").date();
    end   = datetime.strptime(end_date_str, "%m/%d/%Y").date();

    all_moods = [root --> Mood];
    filtered_moods = [];
    for m in all_moods {
        mood_date = date.fromtimestamp(m.ts).strftime("%m/%d/%Y");
        if mood_date >= start_date_str and mood_date <= end_date_str {
            filtered_moods.append(m);
        }
    }
    highs = [m for m in filtered_moods if m.value >= 8];
    lows  = [m for m in filtered_moods if m.value <= 3];
    meds  = [m for m in filtered_moods if m.value > 3 and m.value < 8];

    return {"high": len(highs), "low": len(lows), "medium": len(meds), "total": len(filtered_moods)};
}

def filter_triggers(start_date_str: str, end_date_str: str) -> dict {
    all_trigs = [root --> Trigger];
    filtered_trigs = [];
    for t in all_trigs {
        trigger_date = date.fromtimestamp(t.ts if hasattr(t, 'ts') else 0).strftime("%m/%d/%Y");
        if trigger_date >= start_date_str and trigger_date <= end_date_str {
            filtered_trigs.append(t);
        }
    }
    tag_counts = {};
    for t in filtered_trigs {
        tag_counts[t.tag] = tag_counts.get(t.tag, 0) + 1;
    }
    return tag_counts;
}

########################  INSIGHT WALKERS ########################
"""You are a compassionate wellbeing coach.  
Use ONLY the mood & trigger data from the tools.  
Produce a plain-text summary (3 short paragraphs):  
1. High-level mood trend  
2. Top emotional triggers  
3. One gentle, encouraging next step  
Plain text only, no markdown."""
def generate_summary(start_date_str: str, end_date_str: str) -> str by llm(method="ReAct", tools=[filter_moods, filter_triggers]);

"""Based on the same data, provide 3 specific, actionable suggestions.  
Example: 'When you notice work stress, try a 5-minute breathing exercise.'
Plain text."""
def generate_suggestions(start_date_str: str, end_date_str: str) -> str by llm(method="ReAct", tools=[filter_moods, filter_triggers]);

walker insights {
    has range: str = "last7";
    can start with `root entry {
        (start, end) = get_dates(self.range);
        summary = generate_summary(start, end);
        report {"summary": summary};
    }
}

walker suggestions {
    has range: str = "last7";
    can start with `root entry {
        (start, end) = get_dates(self.range);
        recs = generate_suggestions(start, end);
        report {"suggestions": recs};
    }
}

########################  TREND DATA FOR CHARTS  ########################
def mood_counts(start_date_str: str, end_date_str: str) -> dict {
    start = datetime.strptime(start_date_str, "%m/%d/%Y").date();
    end   = datetime.strptime(end_date_str, "%m/%d/%Y").date();
    dates = []; d = start;
    while d <= end {
        dates.append(d.strftime("%m/%d/%Y"));
        d += timedelta(days=1);
    }

    mood_vals = [];
    trigger_counts = [];
    for day in dates {
        moods = [root --> Mood];
        day_moods = [];
        for m in moods {
            mood_date = date.fromtimestamp(m.ts).strftime("%m/%d/%Y");
            if mood_date == day {
                day_moods.append(m);
            }
        }
        avg = sum(m.value for m in day_moods) / len(day_moods) if day_moods else 0;
        mood_vals.append(avg);

        trigs = [root --> Trigger];
        day_trigs = [];
        for t in trigs {
            trigger_date = date.fromtimestamp(t.ts if hasattr(t, 'ts') else 0).strftime("%m/%d/%Y");
            if trigger_date == day {
                day_trigs.append(t);
            }
        }
        trigger_counts.append(len(day_trigs));
    }

    report {
        "dates": dates,
        "mood_averages": mood_vals,
        "trigger_counts": trigger_counts
    };
}

walker trends {
    has range: str = "last7";
    can start with `root entry {
        (start, end) = get_dates(self.range);
        mood_counts(start, end);  # Inherits report from mood_counts
    }
}