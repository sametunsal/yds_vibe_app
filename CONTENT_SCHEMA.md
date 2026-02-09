{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "YDSCard",
  "type": "object",
  "properties": {
    "id": { "type": "string", "pattern": "^[a-z0-9_]+$" },
    "lemma": { "type": "string" },
    "pos": {
      "type": "string",
      "enum": ["noun", "verb", "adjective", "adverb", "phrasal_verb", "conjunction", "preposition", "prepositional_phrase"]
    },
    "multi_word": { "type": "boolean", "default": false },

    "meanings": {
      "type": "array",
      "items": { "type": "string" },
      "minItems": 1,
      "maxItems": 1
    },

    "synonyms": {
      "type": "array",
      "items": { "type": "string" },
      "minItems": 1,
      "maxItems": 3
    },

    "example": {
      "type": "object",
      "properties": {
        "text": { "type": "string" },
        "translation": { "type": "string" }
      },
      "required": ["text"]
    },

    "cloze": {
      "type": "object",
      "properties": {
        "template": { "type": "string", "description": "Sentence with {{cloze}} placeholder" },
        "answer": { "type": "string", "description": "Exact answer to fill {{cloze}}" }
      },
      "required": ["template", "answer"]
    },

    "tags": {
      "type": "array",
      "items": { "type": "string" }
    },

    "difficulty": { "type": "integer", "minimum": 1, "maximum": 5 }
  },
  "required": ["id", "lemma", "pos", "meanings", "synonyms", "example", "cloze"]
}
