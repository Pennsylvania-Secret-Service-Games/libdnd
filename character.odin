package libdnd
Ancestry :: enum {
	Human,
	Elf,
	Dwarf,
	Halfing,
	Gnome,
	HalfOrc,
	HalfElf,
}

EyeColor :: enum {
	Black,
	Blue,
	Gray,
	Brown,
	Green,
}

HairColor :: enum {
	Red,
	Blonde,
	Brown,
	Black,
}

SkinColor :: enum {
	Fair,
	Tan,
	Olive,
	Dark,
}

Alignment :: enum {
	LawfulGood,
	NeutralGood,
	ChaoticGood,
	LawfulNeutral,
	TrueNeutral,
	ChaoticNeutral,
	LawfulEvil,
	NeutralEvil,
	ChaoticEvil,
}

Class :: enum {
	Assassin,
	Cleric,
	Fighter,
	MagicUser,
	Paladin,
	Ranger,
	Thief,
}

AbilityScore :: enum {
	Strength,
	Dexterity,
	Constitution,
	Intelligence,
	Wisdom,
	Charisma,
}

SkillProficiency :: enum {
	None,
	Trained,
	Expertise,
}

Skill :: enum {
	Acrobatics,
	AnimalHandling,
	Arcana,
	Athletics,
	Deception,
	History,
	Insight,
	Intimidation,
	Investigation,
	Medicine,
	Nature,
	Perception,
	Performance,
	Persuasion,
	Religion,
	SleightOfHand,
	Stealth,
	Survival,
}

@(rodata)
SKILL_BASE_ABILITIES: [Skill]AbilityScore = {
	.Acrobatics     = .Dexterity,
	.AnimalHandling = .Wisdom,
	.Arcana         = .Intelligence,
	.Athletics      = .Strength,
	.Deception      = .Charisma,
	.History        = .Intelligence,
	.Insight        = .Wisdom,
	.Intimidation   = .Charisma,
	.Investigation  = .Intelligence,
	.Medicine       = .Wisdom,
	.Nature         = .Intelligence,
	.Perception     = .Wisdom,
	.Performance    = .Charisma,
	.Persuasion     = .Charisma,
	.Religion       = .Intelligence,
	.SleightOfHand  = .Dexterity,
	.Stealth        = .Dexterity,
	.Survival       = .Wisdom,
}

Weapon :: struct {
	name:        string,
	is_ranged:   bool,
	short_range: int,
	long_range:  int,
	dice:        int,
}

Character :: struct {
	name:           string,
	culture:        Culture,
	ancestry:       Ancestry,
	ability_scores: [AbilityScore]int,
	class:          Class,
	level:          int,
}
