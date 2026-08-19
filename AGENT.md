# Raputa Agent Guide

## 專案摘要

這是一個 Godot 4.7 的 top-down 關卡制遊戲專案。

## 先讀這些

後續 agent 接手時，建議依序讀：

1. `AGENT.md`：目前這份專案導覽。
2. `project.godot`：Godot 版本、autoload、input action、插件設定。
3. 依任務讀相關腳本與場景，例如 `level/base_level.gd`、`skeleton/world.gd`、`system/event/`、`actor/player/player.gd`。

注意：`plan/Plan.md` 目前在一般文字檢視下有編碼亂碼，除非先確認編碼，否則不要把它當成主要規格來源。

## 專案結構

- `project.godot`：主專案設定。主場景是 `level/root.tscn`，autoload 包含 `Event`、`Game`、`Interface`、`Sound`、`DialogueManager`、`World`、`BetterTerrain`。
- `level/`：關卡場景與關卡資料。`base_level.gd` 是關卡基底，`level_data.gd` 定義 `LevelData` resource，`level/level_data/` 放關卡資料資源。
- `actor/`：玩家、NPC、相機與角色 sprite。`actor/player/player.gd` 是玩家主類別
- `system/`：共用系統型別，例如 `Checkpoint`、`SpawnPoint`、`SpawnPointGroup`、存檔資料、狀態機、事件系統與 dialogue balloon。
- `system/event/`：事件樹與事件元件。`EventTree` 會依序執行子節點中的 `BaseEvent`，`ChangeLevelEvent` 目前透過 `World.switch_level()` 切換關卡。
- `interface/`：UI 場景與選單，例如 title、pause、settings、transition、checkpoint menu。
- `data/`：遊戲資料與素材，例如角色資料、tile set、sprite、font、icon。
- `addons/`：第三方插件，目前包含 `dialogue_manager` 與 `better-terrain`。除非任務明確要求，不要修改這裡。

## 目前架構

`level/root.gd` 是 runtime root 的接線點。它把場景中的 `world_node`、音效播放器、UI、transition、player 指派給對應 autoload singleton，例如 `World`、`Sound`、`Interface`。

`skeleton/world.gd` 是目前 `World` autoload 的主要實作。它負責：

- 記錄 `current_level`、`previous_level` 與對應路徑。
- 透過 `switch_level(level_data, spawn_id)` 切換正式關卡。
- 使用 `_load_level()` instantiate 新關卡，或使用 `_load_previous_level()` 回到上一關。
- 切換關卡時呼叫 `current_level.level_set_up(spawn_id)`。

`level/base_level.gd` 是目前關卡基底。現況是每個 `BaseLevel` 場景需要有：

- `MainCamera` 子節點。
- `SpawnPointGroup` 子節點，底下放 `SpawnPoint`。

`BaseLevel.level_set_up(spawn_id)` 會用 `SpawnPoint` 名稱比對 `spawn_id`，設定 `World.camera`、讓相機跟隨 `World.player`，並把玩家與相機移到 spawn 位置。關卡開場若有 `dialogue` 和 `title`，會透過 `Event.dialogue_event()` 播放對話，最後呼叫 `World.player.go_move()`。

`skeleton/game.gd` 是遊戲狀態與存檔入口。現有 `GAMESTATE` 包含 `TITLE`、`PLAYING`、`PAUSED`、`DIALOGUE`、`EVENT`、`TRANSITION`。目前尚未有 `PREVIEW` 狀態。

## 已存在的核心型別

- `Player`：位於 `actor/player/player.gd`，繼承 `CharacterBody2D`。目前處理 input vector、狀態切換 signal，以及基本 `move_and_slide()`。
- `SpawnPoint`：位於 `system/spawn_point.gd`，目前只是 `Marker2D` 基礎型別。現有 `BaseLevel` 以節點名稱比對 spawn id。
- `SpawnPointGroup`：位於 `system/spawn_point_group.gd`，目前只是 `Node` 基礎型別。
- `EventTree`：位於 `system/event/event_tree.gd`，負責把子節點中的 `BaseEvent` 依序執行，執行期間會把 `Game.game_state` 設為 `EVENT`。
- `ChangeLevelEvent`：位於 `system/event/change_level_event.gd`，目前呼叫 `World.switch_level(level_data, spawn_id)`。

## 玩法與資料慣例

- 新增關卡資料時，優先建立或更新 `LevelData` resource，放在 `level/level_data/`。
- 新增角色、玩家能力等資料時，優先使用 `Resource`，放在 `data/` 對應子資料夾。
- 新增事件流程時，優先用 `EventTree` + `BaseEvent` 子類別延伸，不要把一次性劇情邏輯塞進玩家或關卡基底。
- 新增對話時，沿用 `addons/dialogue_manager` 的 resource 與 `dialogue/`、`translation/` 既有流程。
- 新增 input action 先看 `project.godot` 的 `[input]` 區塊，避免和 `up`、`down`、`left`、`right`、`jump`、`event_trigger`、`run`、`pause` 衝突。

## 開發規則

- 優先沿用既有 GDScript、Godot scene、resource、autoload 慣例。
- 不要任意重構 `addons/`。插件問題要先確認是否真的需要改第三方檔案。
- 對 scene 結構有要求的腳本，文件或錯誤訊息要清楚寫出必要子節點，例如 `BaseLevel` 需要 `MainCamera` 與 `SpawnPointGroup`。
- 若修改 `World`、`Game`、`BaseLevel`、`EventTree`，要特別檢查關卡切換、game state、transition、player spawn 是否仍一致。
- 文件中要分清楚「已存在」與「設計方向」。不要把 `plan/` 裡的未完成設計寫成 runtime 現況。

## 驗證建議

這個專案目前沒有明確的自動化測試入口。一般修改後至少要做：

- 在 Godot editor 中打開主場景 `level/root.tscn`，確認沒有 missing script 或 broken exported reference。
- 執行遊戲，確認 title screen、transition、初始關卡載入正常。
- 若改關卡切換，測試 `ChangeLevelEvent`、`World.switch_level()`、spawn id 比對與返回上一關。
- 若改 checkpoint preview，測試 preview 不更新 `Game.save_data.current_level`，取消 preview 後玩家、相機、正式關卡狀態都有還原。
- 若改事件系統，測試 `Game.game_state` 在事件前後會正確恢復。

## Coding Rule

- Keep implementation minimal, simple, and reusable. Avoid overly long or verbose scripts.
- When player or camera nodes are needed, prefer the references exposed by `skeleton/world.gd`.
- When `title_screen` or `pause_screen` UI nodes are needed, prefer the references exposed by `skeleton/interface.gd`.
- When save data is needed, prefer the APIs and state exposed by `skeleton/game.gd`.
