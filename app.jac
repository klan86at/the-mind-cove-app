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
    has title: str;
    has content: str;
    has date: date;

    can get with `analyze entry {
        # Analyze the journal entry content for emotional tone.
        let emotions = analyze_emotions(self.content, self.date, self.title);
        # Store the analysis results in the walker's state.
        StateAgent.state["emotions"] = emotions;
    } 
}

node journal {
    has entries: [journalEntry];

    can get with `summarize entry {
        # Summarize the journal entries.
        let summary = summarize_entries(self.entries);
        # Store the summary in the walker's state.
        StateAgent.state["summary"] = summary;
    }
}

node mentalState {
    has mood: str;
    has stressLevel: int;
    # energyLevel: int;

    can get with `evaluate entry {
        # Evaluate the mental state based on mood and stress level.
        let evaluation = evaluate_mental_state(self.mood, self.stressLevel);
        # Store the evaluation in the walker's state.
        StateAgent.state["mental_evaluation"] = evaluation;
    }
}

node emotion {
    has name: str;
    has intensity: int;
    has triggers: [str];

    can get with `track entry {
        # Track the emotion over time.
        let tracking_info = track_emotion(self.name, self.intensity, self.triggers);
        # Store the tracking info in the walker's state.
        StateAgent.state["emotion_tracking"] = tracking_info;
    }
}

# Relationships
edge trigger {
    has cause: str;
    has intensity: int;
}
edge occurence {
    has state: str;
    has effect: str;
}
edge recordsState {
    has status: str;
}
edge relatedToEmotion {
    has cause: str;
    has relation: bool;
}


with entry {
    root ++> journalEntry(title="sample title", content="sample content", date="2024-06-01");
    root ++> journal(entries=[]);
    root ++> mentalState(mood="neutral", stressLevel=4);
    root ++> emotion(name="anxiety", intensity=5, triggers=["work", "social situations"]);

    agent = StateAgent() spawn root;
}