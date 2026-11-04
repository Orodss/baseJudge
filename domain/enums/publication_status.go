package enums

type PublicationStatus string

type PublicationStatusID int

const (
	PublicationStatusUnknownID   PublicationStatusID = 0
	PublicationStatusDraftID     PublicationStatusID = 1
	PublicationStatusPublishedID PublicationStatusID = 2
	PublicationStatusArchivedID  PublicationStatusID = 3
)

const (
	PublicationStatusUnknown   PublicationStatus = "unknown"
	PublicationStatusDraft     PublicationStatus = "draft"
	PublicationStatusPublished PublicationStatus = "published"
	PublicationStatusArchived  PublicationStatus = "archived"
)

func (v PublicationStatus) IsValid() bool {
	switch v {
	case PublicationStatusDraft, PublicationStatusPublished, PublicationStatusArchived:
		return true
	default:
		return false
	}
}

// ID returns a stable numeric ID, or 0 for unknown values.
func (v PublicationStatus) ID() PublicationStatusID {
	switch v {
	case PublicationStatusDraft:
		return PublicationStatusDraftID
	case PublicationStatusPublished:
		return PublicationStatusPublishedID
	case PublicationStatusArchived:
		return PublicationStatusArchivedID
	default:
		return PublicationStatusUnknownID
	}
}

// PublicationStatusFromID returns Unknown for unrecognized IDs.
func PublicationStatusFromID(id PublicationStatusID) PublicationStatus {
	switch id {
	case PublicationStatusDraftID:
		return PublicationStatusDraft
	case PublicationStatusPublishedID:
		return PublicationStatusPublished
	case PublicationStatusArchivedID:
		return PublicationStatusArchived
	default:
		return PublicationStatusUnknown
	}
}
