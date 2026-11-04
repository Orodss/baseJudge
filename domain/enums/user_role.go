package enums

type UserRole string

type UserRoleID int

const (
	UserRoleUnknownID UserRoleID = 0
	UserRoleAdminID   UserRoleID = 1
	UserRoleGuestID   UserRoleID = 2
)

const (
	UserRoleUnknown UserRole = "unknown"
	UserRoleAdmin   UserRole = "admin"
	UserRoleGuest   UserRole = "guest"
)

func (v UserRole) IsValid() bool {
	switch v {
	case UserRoleAdmin, UserRoleGuest:
		return true
	default:
		return false
	}
}

// ID returns a stable numeric ID, or 0 for unknown values.
func (v UserRole) ID() UserRoleID {
	switch v {
	case UserRoleAdmin:
		return UserRoleAdminID
	case UserRoleGuest:
		return UserRoleGuestID
	default:
		return UserRoleUnknownID
	}
}

// UserRoleFromID returns Unknown for unrecognized IDs.
func UserRoleFromID(id UserRoleID) UserRole {
	switch id {
	case UserRoleAdminID:
		return UserRoleAdmin
	case UserRoleGuestID:
		return UserRoleGuest
	default:
		return UserRoleUnknown
	}
}
