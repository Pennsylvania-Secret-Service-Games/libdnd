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


Character :: struct {
	first_name:                 string,
	last_name:                  string,
	level:                      int,
	class:                      Class,
	ancestry:                   Ancestry,
	culture:                    Culture,
	alignment:                  Alignment,
	height_cm:                  int,
	weight_kg:                  int,
	age:                        int,
	eye_color:                  EyeColor,
	hair_color:                 HairColor,
	skin_color:                 SkinColor,
	proficiency_bonus:          int,
	ability_scores:             [AbilityScore]int,
	saving_throw_proficiencies: [AbilityScore]bool,
	saving_throw_bonuses:       [AbilityScore]int,
	skill_proficiencies:        [Skill]SkillProficiency,
	skill_bonuses:              [Skill]int,
	armor_class_no_armor:       int,
	armor_class_with_armor:     int,
	hit_points:                 int,
	spell_attack_bonus:         int,
	spell_save_dc:              int,
	spell_slots:                [9]int,
	known_spells:               [10][]string,
	prepared_spells:            []string,
}
