package characters
import "../utils"
import "core:fmt"
import "core:math/rand"
import "core:mem"
import "core:strings"
roll_dice :: utils.roll_dice
choose_set :: utils.choose_set
choice :: utils.choice
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
	Gold,
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
	Commoner,
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

Description :: struct {
	height_inches: int,
	weight_pounds: int,
	hair_color:    HairColor,
	eye_color:     EyeColor,
	personality:   [dynamic]string,
}

SavingThrowStats :: struct {
	ability: AbilityScore,
	bonus:   int,
}

SkillStats :: struct {
	skill:     Skill,
	is_expert: bool,
	bonus:     int,
}

Gender :: enum {
	Male,
	Female,
	Nonbinary,
}

Sex :: enum {
	Male,
	Female,
	Intersex,
}

Character :: struct {
	name:                 string,
	gender:               Gender,
	sex:                  Sex,
	class:                Class,
	level:                int,
	proficiency_bonus:    int,
	culture:              Culture,
	ancestry:             Ancestry,
	alignment:            Alignment,
	ability_scores:       [AbilityScore]int,
	height_inches:        int,
	weight_pounds:        int,
	hair_color:           HairColor,
	eye_color:            EyeColor,
	skin_color:           SkinColor,
	personality:          [dynamic]string,
	armor_class:          int,
	armor_name:           string,
	hit_points:           int,
	saving_throws:        [dynamic]SavingThrowStats,
	skills:               [dynamic]SkillStats,
	equipment:            [dynamic]string,
	attacks:              [dynamic]string,
	number_of_attacks:    int,
	sneak_attack_dice:    int,
	spell_attack_bonus:   int,
	spell_save_dc:        int,
	melle_attack_bonus:   int,
	ranged_attack_bonus:  int,
	cantrips:             []string,
	prepared_spell_count: int,
	spell_slots:          [10]int,
	prepared_spells:      []string,
	spellbook:            []string,
}

full_caster_spell_slots :: proc(level: int) -> [10]int {
	if level == 1 {
		return {0, 2, 0, 0, 0, 0, 0, 0, 0, 0}
	} else if level == 2 {
		return {0, 3, 0, 0, 0, 0, 0, 0, 0, 0}
	} else if level == 3 {
		return {0, 4, 2, 0, 0, 0, 0, 0, 0, 0}
	} else if level == 4 {
		return {0, 4, 3, 0, 0, 0, 0, 0, 0, 0}
	} else if level == 5 {
		return {0, 4, 3, 2, 0, 0, 0, 0, 0, 0}
	} else if level == 6 {
		return {0, 4, 3, 3, 0, 0, 0, 0, 0, 0}
	} else if level == 7 {
		return {0, 4, 3, 3, 1, 0, 0, 0, 0, 0}
	} else if level == 8 {
		return {0, 4, 3, 3, 2, 0, 0, 0, 0, 0}
	} else if level == 9 {
		return {0, 4, 3, 3, 3, 1, 0, 0, 0, 0}
	} else if level == 10 {
		return {0, 4, 3, 3, 3, 2, 0, 0, 0, 0}
	} else if level == 11 {
		return {0, 4, 3, 3, 3, 2, 1, 0, 0, 0}
	} else if level == 12 {
		return {0, 4, 3, 3, 3, 2, 1, 0, 0, 0}
	} else if level == 13 {
		return {0, 4, 3, 3, 3, 2, 1, 1, 0, 0}
	} else if level == 14 {
		return {0, 4, 3, 3, 3, 2, 1, 1, 0, 0}
	} else if level == 15 {
		return {0, 4, 3, 3, 3, 2, 1, 1, 1, 0}
	} else if level == 16 {
		return {0, 4, 3, 3, 3, 2, 1, 1, 1, 0}
	} else if level == 17 {
		return {0, 4, 3, 3, 3, 2, 1, 1, 1, 1}
	} else if level == 18 {
		return {0, 4, 3, 3, 3, 3, 1, 1, 1, 1}
	} else if level == 19 {
		return {0, 4, 3, 3, 3, 3, 2, 1, 1, 1}
	} else if level == 20 {
		return {0, 4, 3, 3, 3, 3, 2, 2, 1, 1}
	} else if level > 20 {
		return {0, 4, 3, 3, 3, 3, 2, 2, 2, 1}
	}
	return {}
}

full_caster_highest_spell_level :: proc(level: int) -> int {
	if level == 1 {
		return 1
	} else if level == 1 {
		return 1
	} else if level == 3 {
		return 2
	} else if level == 4 {
		return 2
	} else if level == 5 {
		return 3
	} else if level == 6 {
		return 3
	} else if level == 7 {
		return 4
	} else if level == 8 {
		return 4
	} else if level == 9 {
		return 5
	} else if level == 10 {
		return 5
	} else if level == 11 {
		return 6
	} else if level == 12 {
		return 6
	} else if level == 13 {
		return 7
	} else if level == 14 {
		return 7
	} else if level == 15 {
		return 8
	} else if level == 16 {
		return 8
	} else if level >= 17 {
		return 9
	}
	return 0
}

half_caster_highest_spell_level :: proc(level: int) -> int {
	if level < 5 {
		return 1
	} else if level < 9 {
		return 2
	} else if level < 13 {
		return 3
	} else if level < 17 {
		return 4
	} else {
		return 5
	}
	return 0
}

full_caster_prepared_spells :: proc(level: int) -> int {
	if level == 1 {
		return 4
	} else if level == 2 {
		return 5
	} else if level == 3 {
		return 6
	} else if level == 4 {
		return 7
	} else if level == 5 {
		return 9
	} else if level == 6 {
		return 10
	} else if level == 7 {
		return 11
	} else if level == 8 {
		return 12
	} else if level == 9 {
		return 14
	} else if level == 10 {
		return 15
	} else if level == 11 {
		return 16
	} else if level == 12 {
		return 16
	} else if level == 13 {
		return 17
	} else if level == 14 {
		return 17
	} else if level == 15 {
		return 18
	} else if level == 16 {
		return 18
	} else if level == 17 {
		return 19
	} else if level == 18 {
		return 20
	} else if level == 19 {
		return 21
	} else if level == 20 {
		return 22
	} else if level > 20 {
		return 23
	}
	return 0
}

full_caster_cantrip_count :: proc(level: int) -> int {
	if level == 1 {
		return 3
	} else if level == 2 {
		return 3
	} else if level == 3 {
		return 3
	} else if level == 4 {
		return 4
	} else if level == 5 {
		return 4
	} else if level == 6 {
		return 4
	} else if level == 7 {
		return 4
	} else if level == 8 {
		return 4
	} else if level == 9 {
		return 4
	} else if level >= 10 && level <= 20 {
		return 5
	} else if level > 20 {
		return 6
	}
	return 0
}

half_caster_cantrip_count :: proc(level: int) -> int {
	return 0
}

half_caster_spell_slots :: proc(level: int) -> [10]int {
	if level == 1 {
		return {0, 2, 0, 0, 0, 0, 0, 0, 0, 0}
	} else if level == 2 {
		return {0, 2, 0, 0, 0, 0, 0, 0, 0, 0}
	} else if level == 3 {
		return {0, 3, 0, 0, 0, 0, 0, 0, 0, 0}
	} else if level == 4 {
		return {0, 3, 0, 0, 0, 0, 0, 0, 0, 0}
	} else if level == 5 {
		return {0, 4, 2, 0, 0, 0, 0, 0, 0, 0}
	} else if level == 6 {
		return {0, 4, 2, 0, 0, 0, 0, 0, 0, 0}
	} else if level == 7 {
		return {0, 4, 3, 0, 0, 0, 0, 0, 0, 0}
	} else if level == 8 {
		return {0, 4, 3, 0, 0, 0, 0, 0, 0, 0}
	} else if level == 9 {
		return {0, 4, 3, 2, 0, 0, 0, 0, 0, 0}
	} else if level == 10 {
		return {0, 4, 3, 2, 0, 0, 0, 0, 0, 0}
	} else if level == 11 {
		return {0, 4, 3, 3, 0, 0, 0, 0, 0, 0}
	} else if level == 12 {
		return {0, 4, 3, 3, 0, 0, 0, 0, 0, 0}
	} else if level == 13 {
		return {0, 4, 3, 3, 1, 0, 0, 0, 0, 0}
	} else if level == 14 {
		return {0, 4, 3, 3, 1, 0, 0, 0, 0, 0}
	} else if level == 15 {
		return {0, 4, 3, 3, 2, 0, 0, 0, 0, 0}
	} else if level == 16 {
		return {0, 4, 3, 3, 2, 0, 0, 0, 0, 0}
	} else if level == 17 {
		return {0, 4, 3, 3, 3, 1, 0, 0, 0, 0}
	} else if level == 18 {
		return {0, 4, 3, 3, 3, 1, 0, 0, 0, 0}
	} else if level == 19 {
		return {0, 4, 3, 3, 3, 2, 0, 0, 0, 0}
	} else if level >= 20 {
		return {0, 4, 3, 3, 3, 2, 0, 0, 0, 0}
	}
	return {}
}

half_caster_prepared_spells :: proc(level: int) -> int {
	if level == 1 {
		return 2
	} else if level == 2 {
		return 3
	} else if level == 3 {
		return 4
	} else if level == 4 {
		return 5
	} else if level == 5 {
		return 6
	} else if level == 6 {
		return 6
	} else if level == 7 {
		return 7
	} else if level == 8 {
		return 7
	} else if level == 9 {
		return 9
	} else if level == 10 {
		return 9
	} else if level == 11 {
		return 10
	} else if level == 12 {
		return 10
	} else if level == 13 {
		return 11
	} else if level == 14 {
		return 11
	} else if level == 15 {
		return 12
	} else if level == 16 {
		return 12
	} else if level == 17 {
		return 14
	} else if level == 18 {
		return 14
	} else if level == 19 {
		return 15
	} else if level == 20 {
		return 15
	} else if level > 20 {
		return 16
	}
	return 0
}

generate_name_by_culture :: proc(
	culture: Culture,
	gender: Gender,
	alloc: mem.Allocator,
) -> string {
	name_male := gender == Gender.Male || (gender == Gender.Nonbinary && rand.float32() <= 0.5)
	first_name: string
	last_name: string
	if rand.float32() < 0.9999 {
		if name_male {
			first_name = choice(NAME_TABLE[culture].masc_first_names)
		} else {
			first_name = choice(NAME_TABLE[culture].femme_first_names)
		}
		last_name = choice(NAME_TABLE[culture].last_names)
	} else {
		cult := cast(Culture)rand.int_range(0, len(NAME_TABLE))
		if name_male {
			first_name = choice(NAME_TABLE[cult].masc_first_names)
		} else {
			first_name = choice(NAME_TABLE[cult].femme_first_names)
		}
		if rand.float32() < 0.9 {
			last_name = choice(NAME_TABLE[culture].last_names)
		} else {
			last_name = choice(NAME_TABLE[cult].last_names)
		}
	}
	return fmt.aprintf("%s %s", first_name, last_name, allocator = alloc)
}

generate_gender_by_class :: proc(class: Class) -> Gender {
	tmp := rand.float32()
	perc_binary :: 0.9999
	perc_male: f32 = 0.5
	if class == .Fighter || class == .Paladin {
		perc_male = 0.9
	} else if class == .Cleric {
		perc_male = 0.96
	} else if class == .MagicUser {
		perc_male = 0.3
	}
	if tmp < perc_binary * perc_male {
		return .Male
	} else if tmp < perc_binary * perc_male + perc_binary * (1 - perc_male) {
		return .Female
	} else {
		return .Nonbinary
	}
}


sex_from_gender :: proc(gender: Gender) -> Sex {
	perc_intersex :: 0.01
	perc_trans :: 0.001
	switch gender {
	case .Male:
		if rand.float32() < perc_trans {
			if rand.float32() < perc_intersex {
				return .Intersex
			} else {
				return .Female
			}
		} else {
			return .Male
		}
	case .Female:
		if rand.float32() < perc_trans {
			if rand.float32() < perc_intersex {
				return .Intersex
			} else {
				return .Male
			}
		} else {
			return .Female
		}
	case .Nonbinary:
		if rand.float32() < perc_intersex {
			return .Intersex
		} else {
			if rand.float32() < 0.5 {
				return .Male
			} else {
				return .Female
			}
		}
	}
	return .Intersex
}

ability_mod :: proc(value: int) -> int {
	if value < 10 {
		return (value - 11) / 2
	} else {
		return (value - 10) / 2
	}
}
generate_ability_score :: proc(level: int) -> int {
	return roll_dice(3, 6)
}

generate_normal_ability_score :: proc(level: int) -> int {
	dice: [4]int = {roll_dice(1, 6), roll_dice(1, 6), roll_dice(1, 6), roll_dice(1, 6)}
	min := dice[0]
	out := 0
	for i in dice {
		out += i
		if i < min {
			min = i
		}
	}
	out = out - min
	out += level / 8
	out = clamp(out, 0, 20)
	return out
}

generate_high_ability_score :: proc(level: int) -> int {
	out := roll_dice(2, 4) + 10
	out += level / 4
	out = clamp(out, 0, 20)
	return out
}

generate_stats_by_class :: proc(class: Class, level: int) -> [AbilityScore]int {
	out: [AbilityScore]int
	for &i in out {
		i = generate_normal_ability_score(level)
	}
	switch class {
	case .Assassin:
		out[.Dexterity] = generate_high_ability_score(level)
	case .Cleric:
		out[.Wisdom] = generate_high_ability_score(level)
	case .Commoner:
	case .Fighter:
		out[.Strength] = generate_high_ability_score(level)
	case .MagicUser:
		out[.Intelligence] = generate_high_ability_score(level)
	case .Paladin:
		out[.Strength] = generate_high_ability_score(level)
		out[.Constitution] = generate_high_ability_score(level)
		out[.Charisma] = generate_high_ability_score(level)
		out[.Wisdom] = generate_high_ability_score(level)
	case .Ranger:
		out[.Dexterity] = generate_high_ability_score(level)
	case .Thief:
		out[.Dexterity] = generate_high_ability_score(level)
	}
	return out
}

generate_hit_points_by_class :: proc(class: Class, level: int, constitution: int) -> int {
	mod := ability_mod(constitution)
	hit_die := 6
	switch class {
	case .Assassin:
		hit_die = 8
	case .Cleric:
		hit_die = 8
	case .Commoner:
		hit_die = 4
	case .Fighter:
		hit_die = 10
	case .MagicUser:
		hit_die = 6
	case .Paladin:
		hit_die = 10
	case .Ranger:
		hit_die = 10
	case .Thief:
		hit_die = 8
	}
	hp := hit_die + mod
	for i in 1 ..< level {
		addr := roll_dice(1, hit_die) + mod
		hp += clamp(addr, 0, addr + 2)
	}
	return hp
}


generate_armor :: proc(
	class: Class,
	level: int,
	dexterity: int,
	equipment: ^[dynamic]string,
	is_wealthy: bool,
) -> (
	int,
	string,
) {
	mod := ability_mod(dexterity)
	out_mod := 0
	out_name := "clothing"
	level := level
	if is_wealthy {
		level += 3
	}
	switch class {
	case .Assassin:
		if level < 5 {
			out_mod = 0
		} else if level < 10 {
			out_mod = 1
			out_name = "ring of protection"
			append(equipment, "ring of protection")
		} else {
			out_mod = 2
			out_name = "ring of protection, cloak of protection"
			append(equipment, "ring of protection")
			append(equipment, "cloak of protection")
		}
	case .Cleric:
		if level < 5 {
			out_mod = 6
			out_name = "chain shirt,shield"
			mod = clamp(mod, -8, 2)
			append(equipment, "chain shirt")
			append(equipment, "shield")
		} else if level < 10 {
			out_mod = 8
			out_name = "chain shirt(+1),shield(+1)"
			mod = clamp(mod, -8, 2)
			append(equipment, "chain shirt(+1)")
			append(equipment, "shield(+1)")
		} else if level < 15 {
			out_mod = 10
			out_name = "chain shirt(+2),shield(+2)"
			mod = clamp(mod, -8, 2)
			append(equipment, "chain shirt(+2)")
			append(equipment, "shield(+2)")
		} else {
			out_mod = 11
			out_name = "chain shirt(+3),shield(+2)"
			mod = clamp(mod, -8, 2)
			append(equipment, "chain shirt(+3)")
			append(equipment, "shield(+2)")
		}
	case .Commoner:
	case .Fighter:
		if level < 5 {
			out_mod = 8
			out_name = "chainmail,shield"
			mod = 0
			append(equipment, "chain mail")
			append(equipment, "shield")
		} else if level < 10 {
			out_mod = 10
			out_name = "chainmail(+1),shield(+1)"
			mod = 0
			append(equipment, "chainmail(+1)")
			append(equipment, "shield(+1)")
		} else if level < 15 {
			out_mod = 12
			out_name = "chainmail(+2),shield(+2)"
			mod = 0
			append(equipment, "chainmail(+2)")
			append(equipment, "shield(+2)")
		} else {
			out_mod = 13
			out_name = "chainmail(+3),shield(+2)"
			mod = 0
			append(equipment, "chainmail(+3)")
			append(equipment, "shield(+2)")
		}
	case .MagicUser:
		if level < 5 {
			out_mod = 0
		} else if level < 10 {
			out_mod = 1
			out_name = "ring of protection"
			append(equipment, "ring of protection")
		} else {
			out_mod = 2
			out_name = "ring of protection, cloak of protection"
			append(equipment, "ring of protection")
			append(equipment, "cloak of protection")
		}
	case .Paladin:
		if level < 5 {
			out_mod = 10
			out_name = "plate mail,shield"
			mod = 0
			append(equipment, "plate mail")
			append(equipment, "shield")
		} else if level < 10 {
			out_mod = 12
			out_name = "plate mail(+1),shield(+1)"
			mod = 0
			append(equipment, "plate mail(+1)")
			append(equipment, "shield(+1)")
		} else if level < 15 {
			out_mod = 14
			out_name = "plate mail(+2),shield(+2)"
			mod = 0
			append(equipment, "plate mail(+2)")
			append(equipment, "shield(+2)")
		} else {
			out_mod = 15
			out_name = "plate mail(+3),shield(+2)"
			mod = 0
			append(equipment, "plate mail(+3)")
			append(equipment, "shield(+2)")
		}
	case .Ranger:
		if level < 5 {
			out_mod = 1
			out_name = "leather armor"
			append(equipment, "leather armor")
		} else if level < 10 {
			out_mod = 3
			out_name = "studded leather armor(+1)"
			append(equipment, "studded leather armor(+1)")
		} else if level < 15 {
			out_mod = 4
			out_name = "studded leather armor(+2)"
			append(equipment, "studded leather armor(+2)")
		} else if level < 20 {
			out_mod = 5
			out_name = "studded leather armor(+3)"
			append(equipment, "studded leather armor(+3)")
		}
	case .Thief:
		if level < 5 {
			out_mod = 1
			out_name = "leather armor"
			append(equipment, "leather armor")
		} else if level < 10 {
			out_mod = 3
			out_name = "studded leather armor(+1)"
			append(equipment, "studded leather armor(+1)")
		} else if level < 15 {
			out_mod = 4
			out_name = "studded leather armor(+2)"
			append(equipment, "studded leather armor(+2)")
		} else if level < 20 {
			out_mod = 5
			out_name = "studded leather armor(+3)"
			append(equipment, "studded leather armor(+3)")
		}
	}
	return 10 + mod + out_mod, out_name
}

calculate_proficiency_bonus :: proc(level: int) -> int {
	if level < 4 {
		return 2
	} else if level < 9 {
		return 3
	} else if level < 13 {
		return 4
	} else if level < 17 {
		return 5
	} else if level < 21 {
		return 6
	} else {
		return 7
	}
}

generate_saving_throws :: proc(this: ^Character) {
	switch this.class {
	case .Assassin:
		append(
			&this.saving_throws,
			SavingThrowStats {
				.Dexterity,
				this.proficiency_bonus + ability_mod(this.ability_scores[.Dexterity]),
			},
		)
		append(
			&this.saving_throws,
			SavingThrowStats {
				.Intelligence,
				this.proficiency_bonus + ability_mod(this.ability_scores[.Intelligence]),
			},
		)

	case .Cleric:
		append(
			&this.saving_throws,
			SavingThrowStats {
				.Wisdom,
				this.proficiency_bonus + ability_mod(this.ability_scores[.Wisdom]),
			},
		)
		append(
			&this.saving_throws,
			SavingThrowStats {
				.Constitution,
				this.proficiency_bonus + ability_mod(this.ability_scores[.Constitution]),
			},
		)
	case .Commoner:
	case .Fighter:
		append(
			&this.saving_throws,
			SavingThrowStats {
				.Strength,
				this.proficiency_bonus + ability_mod(this.ability_scores[.Strength]),
			},
		)
		append(
			&this.saving_throws,
			SavingThrowStats {
				.Constitution,
				this.proficiency_bonus + ability_mod(this.ability_scores[.Constitution]),
			},
		)
	case .MagicUser:
		append(
			&this.saving_throws,
			SavingThrowStats {
				.Intelligence,
				this.proficiency_bonus + ability_mod(this.ability_scores[.Intelligence]),
			},
		)
		append(
			&this.saving_throws,
			SavingThrowStats {
				.Wisdom,
				this.proficiency_bonus + ability_mod(this.ability_scores[.Wisdom]),
			},
		)
	case .Paladin:
		append(
			&this.saving_throws,
			SavingThrowStats {
				.Charisma,
				this.proficiency_bonus + ability_mod(this.ability_scores[.Charisma]),
			},
		)
		append(
			&this.saving_throws,
			SavingThrowStats {
				.Wisdom,
				this.proficiency_bonus + ability_mod(this.ability_scores[.Wisdom]),
			},
		)
	case .Ranger:
		append(
			&this.saving_throws,
			SavingThrowStats {
				.Dexterity,
				this.proficiency_bonus + ability_mod(this.ability_scores[.Dexterity]),
			},
		)
		append(
			&this.saving_throws,
			SavingThrowStats {
				.Wisdom,
				this.proficiency_bonus + ability_mod(this.ability_scores[.Wisdom]),
			},
		)
	case .Thief:
		append(
			&this.saving_throws,
			SavingThrowStats {
				.Dexterity,
				this.proficiency_bonus + ability_mod(this.ability_scores[.Dexterity]),
			},
		)
		append(
			&this.saving_throws,
			SavingThrowStats {
				.Intelligence,
				this.proficiency_bonus + ability_mod(this.ability_scores[.Intelligence]),
			},
		)
	}
}

calculate_skill :: proc(this: ^Character, skill: Skill, is_expert: bool) -> SkillStats {
	mod := ability_mod(this.ability_scores[SKILL_BASE_ABILITIES[skill]])
	out: SkillStats
	out.skill = skill
	if is_expert {
		out.is_expert = true
		out.bonus = mod + this.proficiency_bonus * 2
	} else {
		out.bonus = mod + this.proficiency_bonus
	}
	return out
}

generate_skills :: proc(this: ^Character) {
	all_skills: []Skill = {
		.Acrobatics,
		.AnimalHandling,
		.Arcana,
		.Athletics,
		.Deception,
		.History,
		.Insight,
		.Intimidation,
		.Investigation,
		.Medicine,
		.Perception,
		.Nature,
		.Performance,
		.Persuasion,
		.Religion,
		.SleightOfHand,
		.Stealth,
		.Survival,
	}
	skill_count := 4
	switch this.class {
	case .Assassin:
		append(&this.skills, calculate_skill(this, .Stealth, true))
		append(&this.skills, calculate_skill(this, .Deception, true))
		append(&this.skills, calculate_skill(this, .SleightOfHand, false))
		skill_count = 2
	case .Cleric:
		append(&this.skills, calculate_skill(this, .Religion, false))
		skill_count = 3
	case .Commoner:
		skill_count = 5
	case .Fighter:
		skill_count = 3
	case .MagicUser:
		append(&this.skills, calculate_skill(this, .Arcana, this.level >= 2))
		skill_count = 3
	case .Paladin:
		append(&this.skills, calculate_skill(this, .Religion, false))
		skill_count = 3
	case .Ranger:
		append(&this.skills, calculate_skill(this, .Nature, false))
		skill_count = 3
	case .Thief:
		append(&this.skills, calculate_skill(this, .Stealth, true))
		append(&this.skills, calculate_skill(this, .SleightOfHand, true))
		skill_count = 3
	}
	list := make([dynamic]Skill)
	defer delete(list)
	for i in all_skills {
		is_in := false
		for j in this.skills {
			if i == j.skill {
				is_in = true
				break
			}
		}
		if !is_in {
			append(&list, i)
		}
	}
	for i in 0 ..< skill_count {
		idx := rand.int_range(0, len(list))
		append(&this.skills, calculate_skill(this, list[idx], false))
		unordered_remove(&list, idx)
	}
}

calculate_spellcasting :: proc(this: ^Character, alloc: mem.Allocator) {
	switch this.class {
	case .Assassin:
	case .Cleric:
		this.spell_slots = full_caster_spell_slots(this.level)
		this.spell_attack_bonus =
			this.proficiency_bonus + ability_mod(this.ability_scores[.Wisdom])
		this.spell_save_dc = this.spell_attack_bonus + 8
		this.prepared_spell_count = full_caster_prepared_spells(this.level)
		spells := all_castable_spells(this)
		defer delete(spells)
		this.prepared_spells = choose_set(spells[:], this.prepared_spell_count, alloc)
		this.cantrips = choose_set(CLERIC_CANTRIPS, full_caster_cantrip_count(this.level), alloc)
	case .Commoner:
	case .Fighter:
	case .MagicUser:
		known_spells := 6 + (this.level - 1) * 3
		this.spell_slots = full_caster_spell_slots(this.level)
		this.spell_attack_bonus =
			this.proficiency_bonus + ability_mod(this.ability_scores[.Intelligence])
		this.spell_save_dc = this.spell_attack_bonus + 8
		this.prepared_spell_count = full_caster_prepared_spells(this.level)
		spells := all_castable_spells(this)
		this.spellbook = choose_set(spells[:], known_spells, alloc)
		defer delete(spells)
		this.prepared_spells = choose_set(this.spellbook, this.prepared_spell_count, alloc)
		this.cantrips = choose_set(
			MAGIC_USER_CANTRIPS,
			full_caster_cantrip_count(this.level),
			alloc,
		)
	case .Paladin:
		this.spell_slots = half_caster_spell_slots(this.level)
		this.spell_attack_bonus =
			this.proficiency_bonus + ability_mod(this.ability_scores[.Charisma])
		this.spell_save_dc = this.spell_attack_bonus + 8
		this.prepared_spell_count = half_caster_prepared_spells(this.level)
		spells := all_castable_spells(this)
		defer delete(spells)
		this.prepared_spells = choose_set(spells[:], this.prepared_spell_count, alloc)
	case .Ranger:
		this.spell_slots = half_caster_spell_slots(this.level)
		this.spell_attack_bonus =
			this.proficiency_bonus + ability_mod(this.ability_scores[.Wisdom])
		this.spell_save_dc = this.spell_attack_bonus + 8
		this.prepared_spell_count = half_caster_prepared_spells(this.level)
		spells := all_castable_spells(this)
		defer delete(spells)
		this.prepared_spells = choose_set(spells[:], this.prepared_spell_count, alloc)
	case .Thief:
	}
}

all_castable_spells :: proc(this: ^Character) -> [dynamic]string {
	out := make([dynamic]string)
	switch this.class {
	case .Assassin:
		return out
	case .Cleric:
		lv := full_caster_highest_spell_level(this.level)
		for i in 1 ..= lv {
			for j in CLERIC_SPELLS[i] {
				append(&out, j)
			}
		}
	case .Commoner:
		return out
	case .Fighter:
		return out
	case .MagicUser:
		lv := full_caster_highest_spell_level(this.level)
		for i in 1 ..= lv {
			for j in MAGIC_USER_SPELLS[i] {
				append(&out, j)
			}
		}
	case .Paladin:
		lv := half_caster_highest_spell_level(this.level)
		for i in 1 ..= lv {
			for j in PALADIN_SPELLS[i] {
				append(&out, j)
			}
		}
	case .Ranger:
		lv := half_caster_highest_spell_level(this.level)
		for i in 1 ..= lv {
			for j in RANGER_SPELLS[i] {
				append(&out, j)
			}
		}
	case .Thief:
		return out
	}
	return out
}

generate_equipment :: proc(this: ^Character, is_wealthy: bool) {
	switch this.class {
	case .Assassin:
	case .Cleric:
	case .Fighter:
	case .MagicUser:
	case .Paladin:
	case .Commoner:
	case .Ranger:
	case .Thief:
	}
}

create_weapon :: proc(
	this: ^Character,
	ability_score: AbilityScore,
	magic_bonus: int,
	name: string,
	die_count: int,
	die_size: int,
	damage_type: string,
	range: string,
	alloc: mem.Allocator,
	add_to_inventory: bool,
) {
	mod := ability_mod(this.ability_scores[ability_score])
	sneak_attack_msg := ""
	if this.sneak_attack_dice > 0 {
		sneak_attack_msg = fmt.aprintf(
			"(+%dd6 if has advantage or an ally within 5 feet of target)",
			this.sneak_attack_dice,
			allocator = alloc,
		)
	}
	if magic_bonus > 0 {
		if range != "" {
			append(
				&this.attacks,
				fmt.aprintf(
					"%s(+%d):(range %s)+%d to hit damage:%dd%d+%d %s%s",
					name,
					magic_bonus,
					range,
					mod + this.proficiency_bonus + magic_bonus,
					die_count,
					die_size,
					mod + magic_bonus,
					damage_type,
					sneak_attack_msg,
					allocator = alloc,
				),
			)
		} else {
			append(
				&this.attacks,
				fmt.aprintf(
					"%s(+%d):+%d to hit damage:%dd%d+%d %s%s",
					name,
					magic_bonus,
					mod + this.proficiency_bonus + magic_bonus,
					die_count,
					die_size,
					mod + magic_bonus,
					damage_type,
					sneak_attack_msg,
					allocator = alloc,
				),
			)
		}
		if add_to_inventory {
			append(&this.equipment, fmt.aprintf("%s(+%d)", name, magic_bonus, allocator = alloc))
		}
	} else {
		if range != "" {
			append(
				&this.attacks,
				fmt.aprintf(
					"%s:(range %s)+%d to hit damage:%dd%d+%d %s%s",
					name,
					range,
					mod + this.proficiency_bonus + magic_bonus,
					die_count,
					die_size,
					mod + magic_bonus,
					damage_type,
					sneak_attack_msg,
					allocator = alloc,
				),
			)
		} else {
			append(
				&this.attacks,
				fmt.aprintf(
					"%s:+%d to hit damage:%dd%d+%d %s%s",
					name,
					mod + this.proficiency_bonus + magic_bonus,
					die_count,
					die_size,
					mod + magic_bonus,
					damage_type,
					sneak_attack_msg,
					allocator = alloc,
				),
			)
		}
		if add_to_inventory {
			append(&this.equipment, fmt.aprintf("%s)", name, allocator = alloc))
		}
	}
}

generate_attacks :: proc(this: ^Character, is_wealthy: bool, alloc: mem.Allocator) {
	cantrip_die_count := 1
	if this.level > 4 {
		cantrip_die_count = 2
	}
	if this.level > 10 {
		cantrip_die_count = 3
	}
	if this.level > 16 {
		cantrip_die_count = 4
	}
	magic_bonus := clamp((this.level + 3 if is_wealthy else 0) / 3, 0, 3)
	switch this.class {
	case .Assassin:
		this.sneak_attack_dice = (this.level + 1) / 2
		create_weapon(this, .Dexterity, magic_bonus, "dagger", 1, 4, "piercing", "", alloc, true)
		if is_wealthy {
			create_weapon(
				this,
				.Dexterity,
				magic_bonus,
				"hand crossbow",
				1,
				6,
				"piercing",
				"30/120",
				alloc,
				true,
			)
		} else {
			create_weapon(
				this,
				.Dexterity,
				magic_bonus,
				"heavy crossbow",
				1,
				10,
				"piercing",
				"150/600",
				alloc,
				true,
			)
		}
	case .Cleric:
		if rand.float32() < 0.8 {
			create_weapon(
				this,
				.Strength,
				magic_bonus,
				"mace",
				1,
				6,
				"bludgeoning",
				"",
				alloc,
				true,
			)
		} else {
			create_weapon(
				this,
				.Strength,
				magic_bonus,
				"warhammer",
				1,
				8,
				"bludgeoning",
				"",
				alloc,
				true,
			)
		}
		create_weapon(
			this,
			.Dexterity,
			magic_bonus,
			"light crossbow",
			1,
			8,
			"piercing",
			"80/320",
			alloc,
			true,
		)
		has_attack_cantrip: bool = false
		for i in this.cantrips {
			if i == "Sacred Flame" {
				has_attack_cantrip = true
				append(
					&this.attacks,
					fmt.aprintf(
						"Sacred Flame(range 60 feet):dc %d dexterity save, %dd8 radiant damage",
						this.spell_save_dc,
						cantrip_die_count,
						allocator = alloc,
					),
				)
			} else if i == "Toll the Dead" {
				has_attack_cantrip = true
				append(
					&this.attacks,
					fmt.aprintf(
						"Toll the Dead(range 60 feet):dc %d wisdom save, %dd8 necrotic damage(%dd12 if the target is missing any hit points)",
						this.spell_save_dc,
						cantrip_die_count,
						cantrip_die_count,
						allocator = alloc,
					),
				)
			} else if i == "Word of Radiance" {
				has_attack_cantrip = true
				append(
					&this.attacks,
					fmt.aprintf(
						"Word of Radiance:dc %d  consitution save(each creature of your choice within 5 feet of you), %dd6 radiant damage",
						this.spell_save_dc,
						cantrip_die_count,
						allocator = alloc,
					),
				)
			}
		}
		if !has_attack_cantrip {
			this.cantrips[0] = "Sacred Flame"
			append(
				&this.attacks,
				fmt.aprintf(
					"Sacred Flame(range 60 feet):dc %d dexterity save, %dd8 radiant damage",
					this.spell_save_dc,
					cantrip_die_count,
					allocator = alloc,
				),
			)
		}
	case .Fighter:
		if this.level >= 20 {
			this.number_of_attacks = 4
		} else if this.level >= 11 {
			this.number_of_attacks = 3
		} else if this.level >= 5 {
			this.number_of_attacks = 2
		}
		if rand.float32() < 0.2 {
			create_weapon(
				this,
				.Strength,
				magic_bonus,
				"warhammer",
				1,
				8,
				"bludgeoning",
				"",
				alloc,
				true,
			)} else {
			create_weapon(
				this,
				.Strength,
				magic_bonus,
				"longsword",
				1,
				8,
				"slashing",
				"",
				alloc,
				true,
			)
		}
		if rand.float32() < 0.8 {
			create_weapon(
				this,
				.Dexterity,
				magic_bonus,
				"light crossbow",
				1,
				8,
				"piercing",
				"80/320",
				alloc,
				true,
			)
		} else {
			create_weapon(
				this,
				.Dexterity,
				magic_bonus,
				"heavy crossbow",
				1,
				10,
				"piercing",
				"150/600",
				alloc,
				true,
			)
		}
	case .MagicUser:
		if rand.float32() < 0.5 {
			create_weapon(
				this,
				.Strength,
				magic_bonus,
				"staff",
				1,
				8,
				"bludgeoning",
				"",
				alloc,
				true,
			)
		} else {
			create_weapon(
				this,
				.Strength if this.ability_scores[.Strength] > this.ability_scores[.Dexterity] else .Dexterity,
				magic_bonus,
				"dagger",
				1,
				4,
				"piercing",
				"",
				alloc,
				true,
			)
		}
		has_attack_cantrip := false
		for i in this.cantrips {
			if i == "Acid Splash" {
				has_attack_cantrip = true
				append(
					&this.attacks,
					fmt.aprintf(
						"Acid Splash(range 60 feet):each creature in a 5 foot sphere within 60 feet must make a dc %d dexterity save, %dd6 acid damage on a failure",
						this.spell_save_dc,
						cantrip_die_count,
						allocator = alloc,
					),
				)
			} else if i == "Chill Touch" {
				has_attack_cantrip = true
				append(
					&this.attacks,
					fmt.aprintf(
						"Chill Touch(range touch): +%d to hit, on a hit %dd10 necrotic damage and can't regain hit points until the end of your next turn",
						this.spell_attack_bonus,
						cantrip_die_count,
						allocator = alloc,
					),
				)
			} else if i == "Fire Bolt" {
				has_attack_cantrip = true
				append(
					&this.attacks,
					fmt.aprintf(
						"Fire Bolt(range 120 feet): +%d to hit, on a hit %dd10 fire damage, a flammable object hit by this that is not being worn or carried starts burning",
						this.spell_attack_bonus,
						cantrip_die_count,
						allocator = alloc,
					),
				)
			} else if i == "Mind Sliver" {
				has_attack_cantrip = true
				append(
					&this.attacks,
					fmt.aprintf(
						"Mind Sliver(range 60 feet): dc %d intelligence save, on failure %dd6 psychic damage and -1d4 to next saving throw it makes before the start of your next turn",
						this.spell_save_dc,
						cantrip_die_count,
						allocator = alloc,
					),
				)
			} else if i == "Poison Spray" {
				has_attack_cantrip = true
				append(
					&this.attacks,
					fmt.aprintf(
						"Poison Spray(range 30 feet): +%d to hit, on a hit target takes %dd12 poison damage",
						this.spell_attack_bonus,
						cantrip_die_count,
						allocator = alloc,
					),
				)
			} else if i == "Ray of Frost" {
				has_attack_cantrip = true
				append(
					&this.attacks,
					fmt.aprintf(
						"Ray of Frost(range 60 feet): +%d to hit, on a hit target takes %dd8 cold damage and its speed is reduced by 10 feet until the start of your next turn",
						this.spell_attack_bonus,
						cantrip_die_count,
						allocator = alloc,
					),
				)
			} else if i == "Shocking Grasp" {
				has_attack_cantrip = true
				append(
					&this.attacks,
					fmt.aprintf(
						"Shocking Grasp(range touch): +%d to hit, on a hit target takes %dd8 lightning damage and it cannot make opportunity attacks until the start of its next turn",
						this.spell_attack_bonus,
						cantrip_die_count,
						allocator = alloc,
					),
				)
			} else if i == "Toll the Dead" {
				has_attack_cantrip = true
				append(
					&this.attacks,
					fmt.aprintf(
						"Toll the Dead(range 60 feet):dc %d wisdom save, %dd8 necrotic damage(%dd12 if the target is missing any hit points)",
						this.spell_save_dc,
						cantrip_die_count,
						cantrip_die_count,
						allocator = alloc,
					),
				)
			}
		}
		if !has_attack_cantrip {
			if rand.float32() < 0.8 {
				this.cantrips[0] = "Fire Bolt"
				append(
					&this.attacks,
					fmt.aprintf(
						"Fire Bolt(range 120 feet): +%d to hit, on a hit %dd10 fire damage, a flammable object hit by this that is not being worn or carried starts burning",
						this.spell_attack_bonus,
						cantrip_die_count,
						allocator = alloc,
					),
				)
			} else {
				this.cantrips[0] = "Ray of Frost"
				append(
					&this.attacks,
					fmt.aprintf(
						"Ray of Frost(range 60 feet): +%d to hit, on a hit target takes %dd8 cold damage and its speed is reduced by 10 feet until the start of your next turn",
						this.spell_attack_bonus,
						cantrip_die_count,
						allocator = alloc,
					),
				)
			}
		}
	case .Paladin:
		if this.level >= 5 {
			this.number_of_attacks = 2
		}
		if rand.float32() < 0.2 {
			create_weapon(
				this,
				.Strength,
				magic_bonus,
				"warhammer",
				1,
				8,
				"bludgeoning",
				"",
				alloc,
				true,
			)} else {
			create_weapon(
				this,
				.Strength,
				magic_bonus,
				"longsword",
				1,
				8,
				"slashing",
				"",
				alloc,
				true,
			)
		}
		if rand.float32() < 0.8 {
			create_weapon(
				this,
				.Dexterity,
				magic_bonus,
				"light crossbow",
				1,
				8,
				"piercing",
				"80/320",
				alloc,
				true,
			)
		} else {
			create_weapon(
				this,
				.Dexterity,
				magic_bonus,
				"heavy crossbow",
				1,
				10,
				"piercing",
				"150/600",
				alloc,
				true,
			)
		}
	case .Commoner:
		create_weapon(this, .Dexterity, magic_bonus, "dagger", 1, 4, "piercing", "", alloc, true)
	case .Ranger:
		if this.level >= 5 {
			this.number_of_attacks = 2
		}
		if rand.float32() < 0.2 {
			create_weapon(
				this,
				.Strength,
				magic_bonus,
				"warhammer",
				1,
				8,
				"bludgeoning",
				"",
				alloc,
				true,
			)} else {
			create_weapon(
				this,
				.Strength,
				magic_bonus,
				"longsword",
				1,
				8,
				"slashing",
				"",
				alloc,
				true,
			)
		}
		create_weapon(
			this,
			.Dexterity,
			magic_bonus,
			"longbow",
			1,
			8,
			"piercing",
			"150/600",
			alloc,
			true,
		)
	case .Thief:
		this.sneak_attack_dice = (this.level + 1) / 2
		if rand.float32() < 0.5 {
			create_weapon(
				this,
				.Dexterity,
				magic_bonus,
				"dagger",
				1,
				4,
				"piercing",
				"",
				alloc,
				true,
			)
		} else {
			create_weapon(
				this,
				.Dexterity,
				magic_bonus,
				"short sword",
				1,
				6,
				"piercing",
				"",
				alloc,
				true,
			)
		}
		if rand.float32() < 0.2 {
			create_weapon(
				this,
				.Dexterity,
				magic_bonus,
				"hand crossbow",
				1,
				6,
				"piercing",
				"30/120",
				alloc,
				true,
			)
		} else {
			create_weapon(
				this,
				.Dexterity,
				magic_bonus,
				"shortbow",
				1,
				6,
				"piercing",
				"80/320",
				alloc,
				true,
			)
		}
	}
}

generate_appearance :: proc(this: ^Character) {

	switch this.ancestry {
	case .Human:
		this.height_inches = 4 * 12 + 8
		this.weight_pounds = 110
		str_mod := this.ability_scores[.Strength] / 2
		base := roll_dice(2, 10)
		base = clamp(base, str_mod, 40)
		weight_mul := roll_dice(2, 4)
		this.height_inches += base
		this.weight_pounds += base * weight_mul
	case .Elf:
		this.height_inches = 4 * 12 + 6
		this.weight_pounds = 90
		str_mod := this.ability_scores[.Strength] / 2
		base := roll_dice(2, 10)
		base = clamp(base, str_mod, 40)
		weight_mul := roll_dice(1, 4)
		this.height_inches += base
		this.weight_pounds += base * weight_mul
	case .Dwarf:
		this.height_inches = 3 * 12 + 8
		this.weight_pounds = 115
		str_mod := this.ability_scores[.Strength] / 4
		base := roll_dice(2, 4)
		base = clamp(base, str_mod, 40)
		weight_mul := roll_dice(2, 6)
		this.height_inches += base
		this.weight_pounds += base * weight_mul
	case .Halfing:
		this.height_inches = 2 * 12 + 7
		this.weight_pounds = 35
		str_mod := this.ability_scores[.Strength] / 4
		base := roll_dice(2, 4)
		base = clamp(base, str_mod, 40)
		weight_mul := 1
		this.height_inches += base
		this.weight_pounds += base * weight_mul
	case .Gnome:
		this.height_inches = 2 * 12 + 11
		this.weight_pounds = 35
		str_mod := this.ability_scores[.Strength] / 4
		base := roll_dice(2, 4)
		base = clamp(base, str_mod, 40)
		weight_mul := 1
		this.height_inches += base
		this.weight_pounds += base * weight_mul
	case .HalfOrc:
		this.height_inches = 4 * 12 + 10
		this.weight_pounds = 140
		str_mod := this.ability_scores[.Strength] / 2
		base := roll_dice(2, 10)
		base = clamp(base, str_mod, 40)
		weight_mul := roll_dice(2, 6)
		this.height_inches += base
		this.weight_pounds += base * weight_mul
	case .HalfElf:
		this.height_inches = 4 * 12 + 9
		this.weight_pounds = 110
		str_mod := this.ability_scores[.Strength] / 2
		base := roll_dice(2, 8)
		base = clamp(base, str_mod, 40)
		weight_mul := roll_dice(2, 4)
		this.height_inches += base
		this.weight_pounds += base * weight_mul
	}
	random_skin_color :: proc() -> SkinColor {
		tmp := rand.float32()
		if tmp < 0.1 {
			return .Fair
		} else if tmp < 0.5 {
			return .Gold
		} else if tmp < 0.8 {
			return .Olive
		} else {
			return .Dark
		}
	}
	random_hair_color :: proc() -> HairColor {
		tmp := rand.float32()
		if tmp < 0.1 {
			return .Red
		} else if tmp < 0.3 {
			return .Blonde
		} else if tmp < 0.65 {
			return .Brown
		} else {
			return .Black
		}
	}

	random_eye_color :: proc() -> EyeColor {
		tmp := rand.float32()
		if tmp < 0.1 {
			return .Gray
		} else if tmp < 0.35 {
			return .Blue
		} else if tmp < 0.5 {
			return .Green
		} else if tmp < 0.75 {
			return .Brown
		} else {
			return .Black
		}
	}
	oeridian_appearance :: proc(this: ^Character) {
		tmp := rand.float32()
		if tmp < 0.5 {
			this.skin_color = .Gold
		} else if tmp < 0.9 {
			this.skin_color = .Olive
		} else {
			this.skin_color = random_skin_color()
		}
		this.hair_color = random_hair_color()
		tmp2 := rand.float32()
		if tmp2 < 0.5 {
			this.eye_color = .Brown
		} else if tmp2 < 0.9 {
			this.eye_color = .Gray
		} else {
			this.eye_color = random_eye_color()
		}
	}
	suloise_appearance :: proc(this: ^Character) {
		tmp := rand.float32()
		if tmp < 0.95 {
			this.skin_color = .Fair
		} else {
			this.skin_color = random_skin_color()
		}
		tmp2 := rand.float32()
		if tmp2 < 0.2 {
			this.hair_color = .Red
		} else if tmp2 < 0.9 {
			this.hair_color = .Blonde
		} else {
			this.hair_color = random_hair_color()
		}
		tmp3 := rand.float32()
		if tmp3 < 0.5 {
			this.eye_color = .Blue
		} else if tmp3 < 0.9 {
			this.eye_color = .Gray
		} else {
			this.eye_color = random_eye_color()
		}
	}
	baklunish_appearance :: proc(this: ^Character) {
		tmp := rand.float32()
		if tmp < 0.9 {
			this.skin_color = .Gold
		} else {
			this.skin_color = random_skin_color()
		}
		tmp2 := rand.float32()
		if tmp2 < 0.8 {
			this.eye_color = .Green
		} else if tmp2 < 0.9 {
			this.eye_color = .Gray
		} else {
			this.eye_color = random_eye_color()
		}
		tmp3 := rand.float32()
		if tmp3 < 0.6 {
			this.hair_color = .Brown
		} else if tmp3 < 0.9 {
			this.hair_color = .Black
		} else {
			this.hair_color = random_hair_color()
		}
	}
	flannae_appearance :: proc(this: ^Character) {
		this.skin_color = random_skin_color()
		tmp := rand.float32()
		if tmp < 0.5 {
			this.eye_color = .Brown
		} else if tmp < 0.9 {
			this.eye_color = .Black
		} else {
			this.eye_color = random_eye_color()
		}
		tmp2 := rand.float32()
		if tmp2 < 0.9 {
			this.hair_color = .Black
		} else if tmp2 < 0.96 {
			this.hair_color = .Brown
		} else {
			this.hair_color = random_hair_color()
		}
	}
	switch this.culture {
	case .Oeridian:
		oeridian_appearance(this)
	case .Suloise:
		suloise_appearance(this)
	case .Baklunish:
		baklunish_appearance(this)
	case .Flannae:
		flannae_appearance(this)
	case .OeridianSuloise:
		if rand.float32() < 0.5 {
			oeridian_appearance(this)
		} else {
			suloise_appearance(this)
		}
	case .OeridianFlannae:
		if rand.float32() < 0.5 {
			oeridian_appearance(this)
		} else {
			flannae_appearance(this)
		}
	case .Dwarf:
		tmp := rand.float32()
		tmp2 := rand.float32()
		tmp3 := rand.float32()
		if tmp < 0.2 {
			this.skin_color = .Fair
			this.hair_color = random_hair_color()
			this.eye_color = random_eye_color()
		} else if tmp < 0.5 {
			this.skin_color = .Gold
			if tmp2 < 0.5 {
				this.eye_color = .Brown
			} else if tmp2 < 0.9 {
				this.eye_color = .Black
			} else {
				this.eye_color = .Gray
			}
			if tmp3 < 0.5 {
				this.hair_color = .Brown
			} else {
				this.hair_color = .Black
			}
		} else if tmp < 0.8 {
			this.skin_color = .Olive
			if tmp2 < 0.5 {
				this.eye_color = .Brown
			} else if tmp2 < 0.9 {
				this.eye_color = .Black
			} else {
				this.eye_color = .Gray
			}
			if tmp3 < 0.5 {
				this.hair_color = .Brown
			} else {
				this.hair_color = .Black
			}
		} else {
			this.skin_color = .Dark
			if tmp2 < 0.5 {
				this.eye_color = .Brown
			} else if tmp2 < 0.9 {
				this.eye_color = .Black
			} else {
				this.eye_color = .Gray
			}
			if tmp3 < 0.5 {
				this.hair_color = .Brown
			} else {
				this.hair_color = .Black
			}
		}
	case .Elf:
		tmp := rand.float32()
		tmp2 := rand.float32()
		tmp3 := rand.float32()
		if tmp < 0.2 {
			this.skin_color = .Fair
			this.hair_color = random_hair_color()
			this.eye_color = random_eye_color()
		} else if tmp < 0.5 {
			this.skin_color = .Gold
			if tmp2 < 0.5 {
				this.eye_color = .Brown
			} else if tmp2 < 0.9 {
				this.eye_color = .Black
			} else {
				this.eye_color = .Gray
			}
			if tmp3 < 0.5 {
				this.hair_color = .Brown
			} else {
				this.hair_color = .Black
			}
		} else if tmp < 0.8 {
			this.skin_color = .Olive
			if tmp2 < 0.5 {
				this.eye_color = .Brown
			} else if tmp2 < 0.9 {
				this.eye_color = .Black
			} else {
				this.eye_color = .Gray
			}
			if tmp3 < 0.5 {
				this.hair_color = .Brown
			} else {
				this.hair_color = .Black
			}
		} else {
			this.skin_color = .Dark
			if tmp2 < 0.5 {
				this.eye_color = .Brown
			} else if tmp2 < 0.9 {
				this.eye_color = .Black
			} else {
				this.eye_color = .Gray
			}
			if tmp3 < 0.5 {
				this.hair_color = .Brown
			} else {
				this.hair_color = .Black
			}
		}
	case .Gnome:
		tmp := rand.float32()
		tmp2 := rand.float32()
		tmp3 := rand.float32()
		if tmp < 0.2 {
			this.skin_color = .Fair
			this.hair_color = random_hair_color()
			this.eye_color = random_eye_color()
		} else if tmp < 0.5 {
			this.skin_color = .Gold
			if tmp2 < 0.5 {
				this.eye_color = .Brown
			} else if tmp2 < 0.9 {
				this.eye_color = .Black
			} else {
				this.eye_color = .Gray
			}
			if tmp3 < 0.5 {
				this.hair_color = .Brown
			} else {
				this.hair_color = .Black
			}
		} else if tmp < 0.8 {
			this.skin_color = .Olive
			if tmp2 < 0.5 {
				this.eye_color = .Brown
			} else if tmp2 < 0.9 {
				this.eye_color = .Black
			} else {
				this.eye_color = .Gray
			}
			if tmp3 < 0.5 {
				this.hair_color = .Brown
			} else {
				this.hair_color = .Black
			}
		} else {
			this.skin_color = .Dark
			if tmp2 < 0.5 {
				this.eye_color = .Brown
			} else if tmp2 < 0.9 {
				this.eye_color = .Black
			} else {
				this.eye_color = .Gray
			}
			if tmp3 < 0.5 {
				this.hair_color = .Brown
			} else {
				this.hair_color = .Black
			}
		}
	case .Halfing:
		tmp := rand.float32()
		tmp2 := rand.float32()
		tmp3 := rand.float32()
		if tmp < 0.2 {
			this.skin_color = .Fair
			this.hair_color = random_hair_color()
			this.eye_color = random_eye_color()
		} else if tmp < 0.5 {
			this.skin_color = .Gold
			if tmp2 < 0.5 {
				this.eye_color = .Brown
			} else if tmp2 < 0.9 {
				this.eye_color = .Black
			} else {
				this.eye_color = .Gray
			}
			if tmp3 < 0.5 {
				this.hair_color = .Brown
			} else {
				this.hair_color = .Black
			}
		} else if tmp < 0.8 {
			this.skin_color = .Olive
			if tmp2 < 0.5 {
				this.eye_color = .Brown
			} else if tmp2 < 0.9 {
				this.eye_color = .Black
			} else {
				this.eye_color = .Gray
			}
			if tmp3 < 0.5 {
				this.hair_color = .Brown
			} else {
				this.hair_color = .Black
			}
		} else {
			this.skin_color = .Dark
			if tmp2 < 0.5 {
				this.eye_color = .Brown
			} else if tmp2 < 0.9 {
				this.eye_color = .Black
			} else {
				this.eye_color = .Gray
			}
			if tmp3 < 0.5 {
				this.hair_color = .Brown
			} else {
				this.hair_color = .Black
			}
		}
	case:
	}

}
generate_personality :: proc(this: ^Character) {
	align := roll_dice(1, 100)
	if align <= 5 {
		this.alignment = .LawfulEvil
	} else if align <= 10 {
		this.alignment = .NeutralEvil
	} else if align <= 15 {
		this.alignment = .ChaoticEvil
	} else if align <= 25 {
		this.alignment = .LawfulNeutral
	} else if align <= 35 {
		this.alignment = .TrueNeutral
	} else if align <= 45 {
		this.alignment = .ChaoticNeutral
	} else if align <= 60 {
		this.alignment = .ChaoticGood
	} else if align <= 80 {
		this.alignment = .NeutralGood
	} else {
		this.alignment = .LawfulGood
	}
	{
		wealth := roll_dice(1, 10)
		if wealth == 1 {
			append(&this.personality, "Relative Wealth: None")
		} else if wealth == 2 || wealth == 3 {
			append(&this.personality, "Relative Wealth: scant")
		} else if wealth == 4 || wealth == 5 || wealth == 6 || wealth == 7 {
			append(&this.personality, "Relative Wealth: average")
		} else if wealth == 8 {
			append(&this.personality, "Relative Wealth: above average")
		} else if wealth == 9 {
			append(&this.personality, "Relative Wealth: exceptional")
		} else if wealth == 10 {
			append(&this.personality, "Relative Wealth: super abundant")
		}
	}
	{
		generate_apperance := roll_dice(1, 10)
		if generate_apperance == 1 {
			append(&this.personality, "Apperance: dirty")
		} else if generate_apperance == 2 {
			append(&this.personality, "Apperance: clean")
		} else if generate_apperance == 3 {
			append(&this.personality, "Apperance: unkempt")
		} else if generate_apperance == 4 {
			append(&this.personality, "Apperance: immaculate")
		} else if generate_apperance == 5 {
			append(&this.personality, "Apperance: rough")
		} else if generate_apperance == 6 {
			append(&this.personality, "Apperance: ragged")
		} else if generate_apperance == 7 {
			append(&this.personality, "Apperance: dandyish")
		} else if generate_apperance == 8 {
			append(&this.personality, "Apperance: foppish")
		} else if generate_apperance == 9 {
			append(&this.personality, "Apperance: non-descript")
		} else if generate_apperance == 10 {
			append(&this.personality, "Apperance: imposing")
		}
	}
	{
		hit := false
		for {
			sanity := roll_dice(1, 10)
			if sanity == 1 {
				append(&this.personality, "Sanity: very stable")
			} else if sanity == 2 || sanity == 3 || sanity == 4 || sanity == 5 || sanity == 6 {
				append(&this.personality, "Sanity: normal")
			} else if sanity == 7 {
				append(&this.personality, "Sanity: neurotic")
			} else if sanity == 8 {
				append(&this.personality, "Sanity: unstable")
			} else if sanity == 9 {
				if !hit {
					hit = true
					continue
				}
				append(&this.personality, "Sanity: insane")
			} else if sanity == 10 {
				if !hit {
					hit = true
					continue
				}
				append(&this.personality, "Sanity: maniacal")
			}
			break
		}
	}
	{
		general := roll_dice(1, 24)
		if general == 1 {
			append(&this.personality, "General Tendencies: optimist")
		}
		if general == 2 {
			append(&this.personality, "General Tendencies: pessimist")
		} else if general == 3 {
			append(&this.personality, "General Tendencies: hedonist")
		} else if general == 4 {
			append(&this.personality, "General Tendencies: altruist")
		} else if general == 5 {
			append(&this.personality, "General Tendencies: helpful/kindly")
		} else if general == 6 {
			append(&this.personality, "General Tendencies: careless")
		} else if general == 7 {
			append(&this.personality, "General Tendencies: capricious/mischievious")
		} else if general == 8 {
			append(&this.personality, "General Tendencies: sober")
		} else if general == 9 {
			append(&this.personality, "General Tendencies: curious/inquisitive")
		} else if general == 10 {
			append(&this.personality, "General Tendencies: moody")
		} else if general == 11 {
			append(&this.personality, "General Tendencies: trusting")
		} else if general == 12 {
			append(&this.personality, "General Tendencies: suspicious/cautious")
		} else if general == 13 {
			append(&this.personality, "General Tendencies: precise/exacting")
		} else if general == 14 {
			append(&this.personality, "General Tendencies: perceptive")
		} else if general == 15 {
			append(&this.personality, "General Tendencies: opinionated/contrary")
		} else if general == 16 {
			append(&this.personality, "General Tendencies: violent/warlike")
		} else if general == 17 {
			append(&this.personality, "General Tendencies: studious")
		} else if general == 18 {
			append(&this.personality, "General Tendencies: foul/barbaric")
		} else if general == 19 {
			append(&this.personality, "General Tendencies: cruel/callous")
		} else if general == 20 {
			append(&this.personality, "General Tendencies: practical joker/prankster")
		} else if general == 21 {
			append(&this.personality, "General Tendencies: servile/obsequious")
		} else if general == 22 {
			append(&this.personality, "General Tendencies: fanatical/obcessive")
		} else if general == 23 {
			append(&this.personality, "General Tendencies: malevolent")
		} else if general == 24 {
			append(&this.personality, "General Tendencies: loquacious")
		}
	}
	{
		personality_base := roll_dice(1, 8)
		if personality_base == 1 ||
		   personality_base == 2 ||
		   personality_base == 3 ||
		   personality_base == 4 ||
		   personality_base == 5 {
			per := roll_dice(1, 8)
			if per == 1 {
				append(&this.personality, "Personality: modest")
			} else if per == 2 {
				append(&this.personality, "Personality: egoist/arrogant")
			} else if per == 3 {
				append(&this.personality, "Personality: friendly")
			} else if per == 4 {
				append(&this.personality, "Personality: aloof")
			} else if per == 5 {
				append(&this.personality, "Personality: hostile")
			} else if per == 6 {
				append(&this.personality, "Personality: well-spoken")
			} else if per == 7 {
				append(&this.personality, "Personality: diplomatic")
			} else if per == 8 {
				append(&this.personality, "Personality: abrasive")
			}
		} else if personality_base == 6 || personality_base == 7 {
			per := roll_dice(1, 8)
			if per == 1 {
				append(&this.personality, "Personality: forceful(extroverted)")
			} else if per == 2 {
				append(&this.personality, "Personality: overbearing(extroverted)")
			} else if per == 3 {
				append(&this.personality, "Personality: friendly(extroverted)")
			} else if per == 4 {
				append(&this.personality, "Personality: blustering(extroverted)")
			} else if per == 5 {
				append(&this.personality, "Personality: antagonistic(extroverted)")
			} else if per == 6 {
				append(&this.personality, "Personality: rude(extroverted)")
			} else if per == 7 {
				append(&this.personality, "Personality: rash(extroverted)")
			} else if per == 8 {
				append(&this.personality, "Personality: diplomatic(extroverted)")
			}
		} else if personality_base == 8 {
			per := roll_dice(1, 8)
			if per == 1 {
				append(&this.personality, "Personality: retiring(introverted)")
			} else if per == 2 {
				append(&this.personality, "Personality: taciturn(introverted)")
			} else if per == 3 {
				append(&this.personality, "Personality: friendly(introverted)")
			} else if per == 4 {
				append(&this.personality, "Personality: aloof(introverted)")
			} else if per == 5 {
				append(&this.personality, "Personality: hostile(introverted)")
			} else if per == 6 {
				append(&this.personality, "Personality: rude(introverted)")
			} else if per == 7 {
				append(&this.personality, "Personality: courteous(introverted)")
			} else if per == 8 {
				append(&this.personality, "Personality: solitary/secretive(introverted)")
			}
		}
	}
	{
		disp := roll_dice(1, 10)
		if disp == 1 {
			append(&this.personality, "Disposition: cheerful")
		} else if disp == 2 {
			append(&this.personality, "Disposition: morose")
		} else if disp == 3 {
			append(&this.personality, "Disposition: compassionate/sensitive")
		} else if disp == 4 {
			append(&this.personality, "Disposition: unfeeling/insensitive")
		} else if disp == 5 {
			append(&this.personality, "Disposition: humble")
		} else if disp == 6 {
			append(&this.personality, "Disposition: proud/haughty")
		} else if disp == 7 {
			append(&this.personality, "Disposition: even tempered")
		} else if disp == 8 {
			append(&this.personality, "Disposition: hot tempered")
		} else if disp == 9 {
			append(&this.personality, "Disposition: easy going")
		} else if disp == 10 {
			append(&this.personality, "Disposition: harsh")
		}
	}
	{
		intel := roll_dice(1, 10)
		if intel == 1 {
			append(&this.personality, "Intellect: dull")
		} else if intel == 2 {
			append(&this.personality, "Intellect: average")
		} else if intel == 3 {
			append(&this.personality, "Intellect: average")
		} else if intel == 4 {
			append(&this.personality, "Intellect: active")
		} else if intel == 5 {
			append(&this.personality, "Intellect: active")
		} else if intel == 6 {
			append(&this.personality, "Intellect: dreaming")
		} else if intel == 7 {
			append(&this.personality, "Intellect: ponderous")
		} else if intel == 8 {
			append(&this.personality, "Intellect: anti-intellectual")
		} else if intel == 9 {
			append(&this.personality, "Intellect: scheming")
		} else if intel == 10 {
			append(&this.personality, "Intellect: brilliant")
		}
	}
	{
		nature := roll_dice(1, 6)
		if nature == 1 {
			append(&this.personality, "Nature: soft-hearted")
		} else if nature == 2 {
			append(&this.personality, "Nature: forgiving")
		} else if nature == 3 {
			append(&this.personality, "Nature: hard-hearted")
		} else if nature == 4 {
			append(&this.personality, "Nature: unforgiving")
		} else if nature == 5 {
			append(&this.personality, "Nature: jealous")
		} else if nature == 6 {
			append(&this.personality, "Nature: vengeful")
		}
	}
	{
		mat := roll_dice(1, 6)
		if mat == 1 {
			append(&this.personality, "Materialism: aesthetic")
		} else if mat == 2 {
			append(&this.personality, "Materialism: intellectualist")
		} else if mat == 3 {
			append(&this.personality, "Materialism: average")
		} else if mat == 4 {
			append(&this.personality, "Materialism: covetous")
		} else if mat == 5 {
			append(&this.personality, "Materialism: greedy")
		} else if mat == 6 {
			append(&this.personality, "Materialism: avaricious")
		}
	}
	{
		hon := roll_dice(1, 8)
		if hon == 1 {
			append(&this.personality, "Honesty: scrupulous")
		} else if hon == 2 {
			append(&this.personality, "Honesty: very honorable")
		} else if hon == 3 {
			append(&this.personality, "Honesty: truthful")
		} else if hon == 4 {
			append(&this.personality, "Honesty: average")
		} else if hon == 5 {
			append(&this.personality, "Honesty: average")
		} else if hon == 6 {
			append(&this.personality, "Honesty: average")
		} else if hon == 7 {
			append(&this.personality, "Honesty: liar")
		} else if hon == 8 {
			append(&this.personality, "Honesty: deceitful")
		}
	}
	{
		brv := roll_dice(1, 8)
		if brv == 1 {
			append(&this.personality, "Bravery: normal")
		} else if brv == 2 {
			append(&this.personality, "Bravery: normal")
		} else if brv == 3 {
			append(&this.personality, "Bravery: normal")
		} else if brv == 4 {
			append(&this.personality, "Bravery: foolhardy")
		} else if brv == 5 {
			append(&this.personality, "Bravery :brave")
		} else if brv == 6 {
			append(&this.personality, "Bravery: fearless")
		} else if brv == 7 {
			append(&this.personality, "Bravery: cowardly")
		} else if brv == 8 {
			append(&this.personality, "Bravery: craven")
		}
	}
	{
		en := roll_dice(1, 8)
		if en == 1 {
			append(&this.personality, "Energy: slothful")
		} else if en == 2 {
			append(&this.personality, "Energy: lazy")
		} else if en == 3 {
			append(&this.personality, "Energy: normal")
		} else if en == 4 {
			append(&this.personality, "Energy: normal")
		} else if en == 5 {
			append(&this.personality, "Energy: normal")
		} else if en == 6 {
			append(&this.personality, "Energy: energetic")
		} else if en == 7 {
			append(&this.personality, "Energy: energetic")
		} else if en == 8 {
			append(&this.personality, "Energy: driven")
		}
	}
	{
		thr := roll_dice(1, 8)
		if thr == 1 {
			append(&this.personality, "Thrift: miserly")
		} else if thr == 2 {
			append(&this.personality, "Thrift: mean")
		} else if thr == 3 {
			append(&this.personality, "Thrift: thrifty")
		} else if thr == 4 {
			append(&this.personality, "Thrift: average")
		} else if thr == 5 {
			append(&this.personality, "Thrift: average")
		} else if thr == 6 {
			append(&this.personality, "Thrift: spendthrift")
		} else if thr == 7 {
			append(&this.personality, "Thrift: spendthrift")
		} else if thr == 8 {
			append(&this.personality, "Thrift: wastrel")
		}
	}
	{
		hit := false
		for {
			morals := roll_dice(1, 12)
			if morals == 1 {
				append(&this.personality, "Morals: aesthetic")
			} else if morals == 2 {
				append(&this.personality, "Morals: virtuous")
			} else if morals == 3 {
				append(&this.personality, "Morals: normal")
			} else if morals == 4 {
				append(&this.personality, "Morals: normal")
			} else if morals == 5 {
				append(&this.personality, "Morals: lusty")
			} else if morals == 6 {
				append(&this.personality, "Morals: lusty")
			} else if morals == 7 {
				append(&this.personality, "Morals: lustful")
			} else if morals == 8 {
				append(&this.personality, "Morals: immoral")
			} else if morals == 9 {
				append(&this.personality, "Morals: amoral")
			} else if morals == 10 {
				if !hit {
					hit = true
					continue
				}
				append(&this.personality, "Morals: perverted")
			} else if morals == 11 {
				if !hit {
					hit = true
					continue
				}
				append(&this.personality, "Morals: sadistic")
			} else if morals == 12 {
				if !hit {
					hit = true
					continue
				}
				append(&this.personality, "Morals: depraved")
			}
			break
		}
	}
	{
		pie := roll_dice(1, 12)
		if pie == 1 {
			append(&this.personality, "Piety: saintly")
		} else if pie == 2 {
			append(&this.personality, "Piety: martyr/zealot")
		} else if pie == 3 {
			append(&this.personality, "Piety: pious")
		} else if pie == 4 {
			append(&this.personality, "Piety: reverent")
		} else if pie == 5 {
			append(&this.personality, "Piety: average")
		} else if pie == 6 {
			append(&this.personality, "Piety: average")
		} else if pie == 7 {
			append(&this.personality, "Piety: average")
		} else if pie == 8 {
			append(&this.personality, "Piety: average")
		} else if pie == 9 {
			append(&this.personality, "Piety: impious")
		} else if pie == 10 {
			append(&this.personality, "Piety: irreverent")
		} else if pie == 11 {
			append(&this.personality, "Piety: iconoclastic")
		} else if pie == 12 {
			append(&this.personality, "Piety: irreligious")
		}
	}
	{
		intr := roll_dice(1, 24)
		if intr == 1 {
			append(&this.personality, "Interests: religion")
		} else if intr == 2 {
			append(&this.personality, "Interests: legends")
		} else if intr == 3 {
			append(&this.personality, "Interests: history")
		} else if intr == 4 {
			append(&this.personality, "Interests: nature")
		} else if intr == 5 {
			append(&this.personality, "Interests: horticulture")
		} else if intr == 6 {
			append(&this.personality, "Interests: husbandry")
		} else if intr == 7 {
			append(&this.personality, "Interests: exotic animals")
		} else if intr == 8 {
			append(&this.personality, "Interests: hunting")
		} else if intr == 9 {
			append(&this.personality, "Interests: fishing")
		} else if intr == 10 {
			append(&this.personality, "Interests: handicrafts")
		} else if intr == 11 {
			append(&this.personality, "Interests: athletics")
		} else if intr == 12 {
			append(&this.personality, "Interests: politics")
		} else if intr == 13 {
			append(&this.personality, "Interests: wines and spirits")
		} else if intr == 14 {
			append(&this.personality, "Interests: foods and preparation")
		} else if intr == 15 {
			append(&this.personality, "Interests: gambling")
		} else if intr == 16 {
			append(&this.personality, "Interests: drugs")
		} else if intr == 17 || intr == 18 || intr == 19 || intr == 20 {
			col := roll_dice(1, 12)
			if col == 1 {
				append(&this.personality, "Interests: collecting knives and daggers")
			} else if col == 2 {
				append(&this.personality, "Interests: collecting swords")
			} else if col == 3 {
				append(&this.personality, "Interests: collecting weapons")
			} else if col == 4 {
				append(&this.personality, "Interests: collecting shields and weapons")
			} else if col == 5 {
				append(&this.personality, "Interests: collecting armor")
			} else if col == 6 {
				append(&this.personality, "Interests: collecting books and scrolls")
			} else if col == 7 {
				append(&this.personality, "Interests: collecting minerals and gems")
			} else if col == 8 {
				append(&this.personality, "Interests: collecting ornaments and jewelry")
			} else if col == 9 {
				append(&this.personality, "Interests: collecting coins and tokens")
			} else if col == 10 {
				append(&this.personality, "Interests: collecting trophies and skins")
			} else if col == 11 {
				append(&this.personality, "Interests: collecting porcelain, china, and crystal")
			} else if col == 12 {
				append(&this.personality, "Interests: collecting artwork")
			}
		} else if intr == 21 {
			append(&this.personality, "Interests: community service")
		} else if intr == 22 {
			append(&this.personality, "Interests: altruism")
		} else if intr == 23 || intr == 24 {
			append(&this.personality, "Interests: none")
		}
	}
}

generate_character :: proc(
	level: int,
	culture: Culture,
	ancestry: Ancestry,
	class: Class,
	alloc: mem.Allocator,
	is_wealthy := false,
	gender: Maybe(Gender) = nil,
) -> ^Character {
	out := new(Character, alloc)
	out.class = class
	out.level = level
	out.culture = culture
	out.ancestry = ancestry
	out.proficiency_bonus = calculate_proficiency_bonus(level)
	if gender == nil {
		out.gender = generate_gender_by_class(class)
	} else {
		out.gender = gender.(Gender)
	}
	out.sex = sex_from_gender(out.gender)
	out.name = generate_name_by_culture(culture, out.gender, alloc)
	out.ability_scores = generate_stats_by_class(class, level)
	out.hit_points = generate_hit_points_by_class(class, level, out.ability_scores[.Constitution])
	out.equipment = make([dynamic]string, alloc)
	out.armor_class, out.armor_name = generate_armor(
		class,
		level,
		out.ability_scores[.Dexterity],
		&out.equipment,
		is_wealthy,
	)
	out.personality = make([dynamic]string, alloc)
	out.saving_throws = make([dynamic]SavingThrowStats, alloc)
	out.attacks = make([dynamic]string, alloc)
	generate_saving_throws(out)
	generate_skills(out)
	calculate_spellcasting(out, alloc)
	out.number_of_attacks = 1
	generate_attacks(out, is_wealthy, alloc)
	generate_appearance(out)
	generate_personality(out)
	return out
}


format_character :: proc(this: ^Character, alloc: mem.Allocator) -> string {
	alloc_backing: [4096 * 16]u8
	arena: mem.Arena
	mem.arena_init(&arena, alloc_backing[:])
	alloc := mem.arena_allocator(&arena)
	name_line := this.name
	old_all := context.allocator
	context.allocator = alloc
	ancestry_gender_class_level_line := fmt.aprintf(
		"%v %v(born %v) %v(level %v)",
		this.ancestry,
		this.gender,
		this.sex,
		this.class,
		this.level,
	)
	align := ""
	switch this.alignment {
	case .LawfulGood:
		align = "Lawful Good"
	case .NeutralGood:
		align = "Neutral Good"
	case .ChaoticGood:
		align = "Chaotic Good"
	case .LawfulNeutral:
		align = "Lawful Neutral"
	case .TrueNeutral:
		align = "True Neutral"
	case .ChaoticNeutral:
		align = "Chaotic Neutral"
	case .LawfulEvil:
		align = "Lawful Evil"
	case .NeutralEvil:
		align = "Neutral Evil"
	case .ChaoticEvil:
		align = "Chaotic Evil"
	}
	culture_line := fmt.aprintf("Culture: %v Alignment: %v", this.culture, align)
	ability_line := fmt.aprintf(
		"strength:%d dexterity:%d constitution:%d intelligence:%d wisdom:%d charisma:%d",
		this.ability_scores[.Strength],
		this.ability_scores[.Dexterity],
		this.ability_scores[.Constitution],
		this.ability_scores[.Intelligence],
		this.ability_scores[.Wisdom],
		this.ability_scores[.Charisma],
	)
	stats_line := fmt.aprintf(
		"Armor Class: %d(%s) Hit Points: %d",
		this.armor_class,
		this.armor_name,
		this.hit_points,
	)
	saves := fmt.aprintf("Saving Throws: ")
	for i, idx in this.saving_throws {
		tmp: string
		if idx + 1 < len(this.saving_throws) {
			if i.bonus > 0 {
				tmp = fmt.aprintf("%v(+%d), ", i.ability, i.bonus)
			} else {
				tmp = fmt.aprintf("%v(%d), ", i.ability, i.bonus)
			}
		} else {
			if i.bonus > 0 {
				tmp = fmt.aprintf("%v(+%d)", i.ability, i.bonus)
			} else {
				tmp = fmt.aprintf("%v(%d)", i.ability, i.bonus)
			}
		}
		saves = strings.concatenate({saves, tmp})
	}
	skills := fmt.aprintf("Skills: ")
	for i, idx in this.skills {
		tmp: string
		if i.is_expert {
			if idx + 1 < len(this.skills) {
				if i.bonus > 0 {
					tmp = fmt.aprintf("%v(+%d)(expert), ", i.skill, i.bonus)
				} else {
					tmp = fmt.aprintf("%v(%d)(expert), ", i.skill, i.bonus)
				}
			} else {
				if i.bonus > 0 {
					tmp = fmt.aprintf("%v(+%d)(expert)", i.skill, i.bonus)
				} else {
					tmp = fmt.aprintf("%v(%d)(expert)", i.skill, i.bonus)
				}
			}
		} else {
			if idx + 1 < len(this.skills) {
				if i.bonus > 0 {
					tmp = fmt.aprintf("%v(+%d), ", i.skill, i.bonus)
				} else {
					tmp = fmt.aprintf("%v(%d), ", i.skill, i.bonus)
				}
			} else {
				if i.bonus > 0 {
					tmp = fmt.aprintf("%v(+%d)", i.skill, i.bonus)
				} else {
					tmp = fmt.aprintf("%v(%d)", i.skill, i.bonus)
				}
			}
		}
		skills = strings.concatenate({skills, tmp})
	}
	attacks := fmt.aprintf("Attacks(%d weapon attacks per round):", this.number_of_attacks)
	for i, _idx in this.attacks {
		attacks = strings.concatenate({attacks, "\n\t", i})
	}
	equipment := fmt.aprintf("Equipment: ")
	for i, _idx in this.equipment {
		if _idx == 0 {
			equipment = strings.concatenate({equipment, i})
		} else {
			equipment = strings.concatenate({equipment, ", ", i})
		}
	}
	height_feet := this.height_inches / 12
	height_inches := this.height_inches % 12
	physical_description := fmt.aprintf(
		"Height:%d\"%d' Weight: %d lb Hair Color: %v Eye Color:%v Skin Color:%v ",
		height_feet,
		height_inches,
		this.weight_pounds,
		this.hair_color,
		this.eye_color,
		this.skin_color,
	)
	cantrips := fmt.aprintf("Cantrips: ")
	for i, _idx in this.cantrips {
		if _idx == 0 {
			cantrips = strings.concatenate({cantrips, i})
		} else {
			cantrips = strings.concatenate({cantrips, ", ", i})
		}
	}
	spell_slots := fmt.aprintf(
		"Spell Slots: First Level:%d Second Level:%d Third Level:%d Fourth Level:%d Fifth Level:%d Sixth Level:%d Seventh Level:%d Eight Level:%d Ninth Level:%d",
		this.spell_slots[1],
		this.spell_slots[2],
		this.spell_slots[3],
		this.spell_slots[4],
		this.spell_slots[5],
		this.spell_slots[6],
		this.spell_slots[7],
		this.spell_slots[8],
		this.spell_slots[9],
	)
	prepared_spells := fmt.aprintf(
		"Prepared Spells(can prepare %d spells): ",
		this.prepared_spell_count,
	)
	for i, _idx in this.prepared_spells {
		if _idx == 0 {
			prepared_spells = strings.concatenate({prepared_spells, i})
		} else {
			prepared_spells = strings.concatenate({prepared_spells, ", ", i})
		}
	}
	spellbook := fmt.aprintf("Spellbook: ")
	for i, _idx in this.spellbook {
		if _idx == 0 {
			spellbook = strings.concatenate({spellbook, i})
		} else {
			spellbook = strings.concatenate({spellbook, ", ", i})
		}
	}
	personality := fmt.aprintf("Personality:\n\t")
	for i, _idx in this.personality {
		if _idx == 0 {
			personality = strings.concatenate({personality, i})
		} else {
			personality = strings.concatenate({personality, "\n\t", i})
		}
	}
	return strings.concatenate(
		{
			name_line,
			"\n",
			ancestry_gender_class_level_line,
			"\n",
			culture_line,
			"\n",
			ability_line,
			"\n",
			stats_line,
			"\n",
			saves,
			"\n",
			skills,
			"\n",
			attacks,
			"\n",
			equipment,
			"\n",
			physical_description,
			"\n",
			cantrips,
			"\n",
			spell_slots,
			"\n",
			prepared_spells,
			"\n",
			spellbook,
			"\n",
			personality,
		},
		alloc,
	)
}
