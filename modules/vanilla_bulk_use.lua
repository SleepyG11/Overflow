Overflow.bulk_use_functions = {
    c_black_hole = function(self, _, _, amount)
        update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname=localize('k_all_hands'),chips = '...', mult = '...', level=''})
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2, func = function()
            play_sound('tarot1')
            self:juice_up(0.8, 0.5)
            G.TAROT_INTERRUPT_PULSE = true
            return true end }))
        update_hand_text({delay = 0}, {mult = '+', StatusText = true})
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.9, func = function()
            play_sound('tarot1')
            self:juice_up(0.8, 0.5)
            return true end }))
        update_hand_text({delay = 0}, {chips = '+', StatusText = true})
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.9, func = function()
            play_sound('tarot1')
            self:juice_up(0.8, 0.5)
            G.TAROT_INTERRUPT_PULSE = nil
            return true end }))
        update_hand_text({sound = 'button', volume = 0.7, pitch = 0.9, delay = 0}, {level='+'..(amount or 1)})
        delay(1.3)
        for k, v in pairs(G.GAME.hands) do
            level_up_hand(self, k, true, amount or 1)
        end
        update_hand_text({sound = 'button', volume = 0.7, pitch = 1.1, delay = 0}, {mult = 0, chips = 0, handname = '', level = ''})
    end,
    c_temperance = function(self, _, _, amount)
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
            play_sound('timpani')
            self:juice_up(0.3, 0.5)
            ease_dollars(self.ability.money * (amount or 1), true)
            return true end }))
        delay(0.6)
    end,
    c_hermit = function(self, _, _, amount)
        local cap = to_big(self.ability.extra)
        local new_money = to_big(G.GAME.dollars)
        local multi_amount = to_big(amount)
        local diff = to_big(0)
        if new_money > to_big(0) then
            while new_money < cap and multi_amount > 0 do
                new_money = new_money * 2
                multi_amount = multi_amount - 1
            end
            new_money = new_money + cap * multi_amount
            diff = new_money - G.GAME.dollars
        end
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
            play_sound('timpani')
            self:juice_up(0.3, 0.5)
            ease_dollars(diff, true)
            return true end }))
        delay(0.6)
    end
}

Overflow.bulk_use_caps = Overflow.bulk_use_caps or {}
Overflow.table_merge(Overflow.bulk_use_caps, {
    c_judgement = function(self, area, _, amount)
        return math.max(0, math.min(amount, G.jokers.config.card_limit - #G.jokers.cards))
    end,

    c_wraith = function(self, area, _, amount)
        return math.max(0, math.min(amount, G.jokers.config.card_limit - #G.jokers.cards))
    end,
    c_soul = function(self, area, _, amount)
        return math.max(0, math.min(amount, G.jokers.config.card_limit - #G.jokers.cards))
    end,
    c_ectoplasm = function(self, area, _, amount)
        return math.max(0, math.min(amount, #self.eligible_editionless_jokers))
    end,
    c_hex = function(self, area, _, amount)
        local editionless_eternal_jokers = 0
        for i, card in ipairs(self.eligible_editionless_jokers) do
            if card.ability and card.ability.eternal then editionless_eternal_jokers = editionless_eternal_jokers + 1 end
        end
        return math.max(0, math.min(amount, editionless_eternal_jokers))
    end,
    c_ankh = function(self, area, _, amount)
        local has_eternal = false
        for i, card in ipairs(G.jokers.cards) do
            if card.ability and card.ability.eternal then has_eternal = true break end
        end
        return math.max(0, math.min(amount, has_eternal and amount or 1))
    end,
    c_immolate = function(self, area, _, amount)
        return math.max(0, math.min(amount, math.ceil(#G.hand.cards / self.ability.extra.destroy)))
    end,
})

local init_prototypesref = Game.init_item_prototypes
function Game:init_item_prototypes()
    init_prototypesref(self)
    for i, v in pairs(G.P_CENTERS) do
        if v.set == "Planet" and not v.original_mod then
            Overflow.bulk_use_functions[v.key] = function(self, area, _, amount)
                update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname=localize(self.ability.consumeable.hand_type, 'poker_hands'),chips = G.GAME.hands[self.ability.consumeable.hand_type].chips, mult = G.GAME.hands[self.ability.consumeable.hand_type].mult, level=G.GAME.hands[self.ability.consumeable.hand_type].level})
                level_up_hand(self, self.ability.consumeable.hand_type, nil, amount or 1)
                update_hand_text({sound = 'button', volume = 0.7, pitch = 1.1, delay = 0}, {mult = 0, chips = 0, handname = '', level = ''})
            end
        end
    end
end