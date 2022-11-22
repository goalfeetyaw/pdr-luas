local ffi = require "ffi"
ffi.cdef[[
    struct c_animstate { 
        char pad[ 3 ];
        char m_bForceWeaponUpdate; //0x5
        char pad1[ 91 ];
        void* m_pBaseEntity; //0x60
        void* m_pActiveWeapon; //0x64
        void* m_pLastActiveWeapon; //0x68
        float m_flLastClientSideAnimationUpdateTime; //0x6C
        int m_iLastClientSideAnimationUpdateFramecount; //0x70
        float m_flAnimUpdateDelta; //0x74
        float m_flEyeYaw; //0x78
        float m_flPitch; //0x7C
        float m_flGoalFeetYaw; //0x80
        float m_flCurrentFeetYaw; //0x84
        float m_flCurrentTorsoYaw; //0x88
        float m_flUnknownVelocityLean; //0x8C
        float m_flLeanAmount; //0x90
        char pad2[ 4 ];
        float m_flFeetCycle; //0x98
        float m_flFeetYawRate; //0x9C
        char pad3[ 4 ];
        float m_fDuckAmount; //0xA4
        float m_fLandingDuckAdditiveSomething; //0xA8
        char pad4[ 4 ];
        float m_vOriginX; //0xB0
        float m_vOriginY; //0xB4
        float m_vOriginZ; //0xB8
        float m_vLastOriginX; //0xBC
        float m_vLastOriginY; //0xC0
        float m_vLastOriginZ; //0xC4
        float m_vVelocityX; //0xC8
        float m_vVelocityY; //0xCC
        char pad5[ 4 ];
        float m_flUnknownFloat1; //0xD4
        char pad6[ 8 ];
        float m_flUnknownFloat2; //0xE0
        float m_flUnknownFloat3; //0xE4
        float m_flUnknown; //0xE8
        float m_flSpeed2D; //0xEC
        float m_flUpVelocity; //0xF0
        float m_flSpeedNormalized; //0xF4
        float m_flFeetSpeedForwardsOrSideWays; //0xF8
        float m_flFeetSpeedUnknownForwardOrSideways; //0xFC
        float m_flTimeSinceStartedMoving; //0x100
        float m_flTimeSinceStoppedMoving; //0x104
        bool m_bOnGround; //0x108
        bool m_bInHitGroundAnimation; //0x109
        float m_flTimeSinceInAir; //0x10A
        float m_flLastOriginZ; //0x10E
        float m_flHeadHeightOrOffsetFromHittingGroundAnimation; //0x112
        float m_flStopToFullRunningFraction; //0x116
        char pad7[ 4 ]; //0x11A
        float m_flMagicFraction; //0x11E
        char pad8[ 60 ]; //0x122
        float m_flWorldForce; //0x15E
        char pad9[ 462 ]; //0x162
        float m_flMaxYaw; //0x334
    };
]]


local rawientitylist = client.create_interface('client.dll', 'VClientEntityList003') or error('VClientEntityList003 wasnt found', 2)

local ientitylist = ffi.cast("void***", rawientitylist) or error('rawientitylist is nil', 2)
local get_client_entity = ffi.cast('void*(__thiscall*)(void*, int)', ientitylist[0][3]) or error('get_client_entity is nil', 2)

function get_animstate(_Entity)
    if not (_Entity) then
        return
    end
    local player_ptr = ffi.cast( "void***", get_client_entity(ientitylist, _Entity))
    local animstate_ptr = ffi.cast( "char*" , player_ptr ) + 0x9960
    local state = ffi.cast( "struct c_animstate**", animstate_ptr )[0]

    return state
end

local anims  = ui.add_multi_dropdown("Animations" , {"0 Pitch" , "Static legs" , "Backwards legs"})
local leg_ref = ui.get("Misc","General", "Movement", "Leg movement")

callbacks.register("post_anim_update", function()

    local lp = engine.get_local_player()

    if not lp or not client.is_alive() then return end

    local animstate = get_animstate(lp)
    local lp_ent =  entity_list.get_client_entity(lp)

    local m_flPoseParameter = lp_ent:get_prop("DT_BaseAnimating", "m_flPoseParameter");    

    if anims:get("0 Pitch") then 
        if animstate.m_bInHitGroundAnimation and animstate.m_bOnGround then 
            m_flPoseParameter:set_float_index(12, 0.45);
        end
    end

    if anims:get("Static legs") then 
        m_flPoseParameter:set_float_index(6, 1); 
    end

    if anims:get("Backwards legs") then 
        m_flPoseParameter:set_float_index(0, 1);
        leg_ref:set(3)
    end

end)
