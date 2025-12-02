import from byllm.lib { Model }

glob llm = Model(model_name="gpt-4"); 

walker StateAgent {
    # This dictionary will hold the data collected during the journey.
    has state: dict = {};

    # The walker's journey starts at the root node.
    can start with `root entry {
        # From the root, visit all directly connected nodes.
        visit [-->];
    }
}

node journalEntry {
    title: str;
    content: str
    date: date;

    can get with `analyze {
        # Analyze the journal entry content for emotional tone.
        let emotions = analyze_emotions(self.content, self.date, self.title);
        # Store the analysis results in the walker's state.
        StateAgent.state["emotions"] = emotions;
    }
}

node journal {
    entries: [journalEntry];

    can get with `summarize {
        # Summarize the journal entries.
        let summary = summarize_entries(self.entries);
        # Store the summary in the walker's state.
        StateAgent.state["summary"] = summary;
    }
}

node mentalState {
    mood: str;
    stressLevel: int;
    # energyLevel: int;

    can get with `evaluate {
        # Evaluate the mental state based on mood and stress level.
        let evaluation = evaluate_mental_state(self.mood, self.stressLevel);
        # Store the evaluation in the walker's state.
        StateAgent.state["mental_evaluation"] = evaluation;
    }
}

node emotion {
    name: str;
    intensity: int;
    triggers: [str];

    can get with `track {
        # Track the emotion over time.
        let tracking_info = track_emotion(self.name, self.intensity, self.triggers);
        # Store the tracking info in the walker's state.
        StateAgent.state["emotion_tracking"] = tracking_info;
    }
}

# Relationships
edge trigger {
    cause: str;
    intensity: int;
}
edge occurence {
    state: str;
    effect: str;
}
edge recordsState {
    status: str;
}
edge relatedToEmotion {
    cause: str;
    relation: bool;
}


with entry {
    root ++> journalEntry();
    root ++> journal();
    root ++> mentalState();
    root ++> emotion();

    agent = StateAgent() spawn root;
}
