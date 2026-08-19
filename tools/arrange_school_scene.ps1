$ErrorActionPreference = "Stop"

$ProjectRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$SourceScenePath = Join-Path $ProjectRoot "level\school.tscn"
$OutputScenePath = Join-Path $ProjectRoot "level\school_arranged.tscn"
$OutputLevelDataPath = Join-Path $ProjectRoot "level\level_data\school_arranged.tres"
$PreviewPath = Join-Path $ProjectRoot "plan\school_arranged_preview.png"
$TileSize = 48

function New-TileRecord {
	param(
		[int]$X,
		[int]$Y,
		[int]$Source,
		[int]$AtlasX,
		[int]$AtlasY,
		[int]$Alternative = 0
	)

	[pscustomobject]@{
		X = $X
		Y = $Y
		Source = $Source
		AtlasX = $AtlasX
		AtlasY = $AtlasY
		Alternative = $Alternative
	}
}

function Read-LayerRecords {
	param(
		[string]$SceneText,
		[string]$LayerName
	)

	$pattern = '(?s)\[node name="' + [regex]::Escape($LayerName) + '" type="TileMapLayer".*?tile_map_data = PackedByteArray\("([^"]*)"\)'
	$match = [regex]::Match($SceneText, $pattern)
	if (-not $match.Success) {
		return @()
	}

	$bytes = [Convert]::FromBase64String($match.Groups[1].Value)
	$records = New-Object System.Collections.ArrayList
	for ($i = 2; $i -lt $bytes.Length; $i += 12) {
		[void]$records.Add((New-TileRecord `
			-X ([BitConverter]::ToInt16($bytes, $i)) `
			-Y ([BitConverter]::ToInt16($bytes, $i + 2)) `
			-Source ([BitConverter]::ToInt16($bytes, $i + 4)) `
			-AtlasX ([BitConverter]::ToInt16($bytes, $i + 6)) `
			-AtlasY ([BitConverter]::ToInt16($bytes, $i + 8)) `
			-Alternative ([BitConverter]::ToInt16($bytes, $i + 10))))
	}

	@($records)
}

function Get-CommonSamples {
	param([object[]]$Records)

	$groups = $Records |
		Group-Object { "$($_.Source),$($_.AtlasX),$($_.AtlasY),$($_.Alternative)" } |
		Sort-Object Count -Descending

	$samples = New-Object System.Collections.ArrayList
	foreach ($group in $groups) {
		[void]$samples.Add($group.Group[0])
	}

	@($samples)
}

function Select-Sample {
	param(
		[object[]]$Samples,
		[int]$X,
		[int]$Y,
		[int]$Limit = 5
	)

	if ($Samples.Count -eq 0) {
		throw "No tile samples available."
	}

	$max = [Math]::Min($Samples.Count, $Limit)
	$index = [Math]::Abs(($X * 31) + ($Y * 17)) % $max
	$sample = $Samples[$index]
	New-TileRecord -X $X -Y $Y -Source $sample.Source -AtlasX $sample.AtlasX -AtlasY $sample.AtlasY -Alternative $sample.Alternative
}

function Copy-Records {
	param(
		[object[]]$Records,
		[int]$DestinationX,
		[int]$DestinationY,
		[int]$MinX,
		[int]$MinY,
		[int]$MaxX,
		[int]$MaxY
	)

	if ($Records.Count -eq 0) {
		return @()
	}

	$sourceMinX = ($Records | Measure-Object X -Minimum).Minimum
	$sourceMinY = ($Records | Measure-Object Y -Minimum).Minimum
	$offsetX = $DestinationX - $sourceMinX
	$offsetY = $DestinationY - $sourceMinY

	$result = New-Object System.Collections.ArrayList
	foreach ($record in $Records) {
		$x = $record.X + $offsetX
		$y = $record.Y + $offsetY
		if ($x -lt $MinX -or $x -gt $MaxX -or $y -lt $MinY -or $y -gt $MaxY) {
			continue
		}

		[void]$result.Add((New-TileRecord -X $x -Y $y -Source $record.Source -AtlasX $record.AtlasX -AtlasY $record.AtlasY -Alternative $record.Alternative))
	}

	@($result)
}

function Encode-LayerRecords {
	param([object[]]$Records)

	$bytes = New-Object System.Collections.ArrayList
	[void]$bytes.Add([byte]0)
	[void]$bytes.Add([byte]0)

	foreach ($record in ($Records | Sort-Object Y, X, Source, AtlasX, AtlasY)) {
		foreach ($value in @($record.X, $record.Y, $record.Source, $record.AtlasX, $record.AtlasY, $record.Alternative)) {
			[void]$bytes.AddRange([BitConverter]::GetBytes([int16]$value))
		}
	}

	[Convert]::ToBase64String([byte[]]$bytes.ToArray([byte]))
}

function Set-LayerData {
	param(
		[string]$SceneText,
		[string]$LayerName,
		[object[]]$Records
	)

	$data = Encode-LayerRecords -Records $Records
	$pattern = '(?s)(\[node name="' + [regex]::Escape($LayerName) + '" type="TileMapLayer".*?)(?:tile_map_data = PackedByteArray\("[^"]*"\)\r?\n)?(tile_set = ExtResource\("[^"]+"\))'
	[regex]::Replace($SceneText, $pattern, "`$1tile_map_data = PackedByteArray(`"$data`")`r`n`$2", 1)
}

function Add-FilledRect {
	param(
		[System.Collections.ArrayList]$Target,
		[object[]]$Samples,
		[int]$MinX,
		[int]$MinY,
		[int]$MaxX,
		[int]$MaxY,
		[int]$SampleLimit = 5
	)

	for ($y = $MinY; $y -le $MaxY; $y++) {
		for ($x = $MinX; $x -le $MaxX; $x++) {
			[void]$Target.Add((Select-Sample -Samples $Samples -X $x -Y $y -Limit $SampleLimit))
		}
	}
}

function Add-Point {
	param(
		[System.Collections.ArrayList]$Target,
		[object[]]$Samples,
		[int]$X,
		[int]$Y,
		[int]$SampleLimit = 5
	)

	[void]$Target.Add((Select-Sample -Samples $Samples -X $X -Y $Y -Limit $SampleLimit))
}

function Add-CopiedRecords {
	param(
		[System.Collections.ArrayList]$Target,
		[object[]]$Records,
		[int]$DestinationX,
		[int]$DestinationY,
		[int]$MinX,
		[int]$MinY,
		[int]$MaxX,
		[int]$MaxY
	)

	foreach ($record in @(Copy-Records -Records $Records -DestinationX $DestinationX -DestinationY $DestinationY -MinX $MinX -MinY $MinY -MaxX $MaxX -MaxY $MaxY)) {
		[void]$Target.Add($record)
	}
}

function Save-PreviewImage {
	param([hashtable]$LayerRecords)

	Add-Type -AssemblyName System.Drawing

	$sourceImages = @{
		Floor = @{
			1 = Join-Path $ProjectRoot "data\tileset\school\pika_nos_in_tiles02_A2_Godot.png"
			2 = Join-Path $ProjectRoot "data\tileset\school\pika_nos_in_tiles02_A4_Godot(1).png"
		}
		Wall = @{
			0 = Join-Path $ProjectRoot "data\tileset\school\pika_nos_in_tiles02_A4_Godot.png"
		}
		Deco = @{
			0 = Join-Path $ProjectRoot "data\tileset\school\pika_nos_in_tiles02_B.png"
			1 = Join-Path $ProjectRoot "data\tileset\school\pika_nos_in_tiles02_C.png"
			2 = Join-Path $ProjectRoot "data\tileset\school\pika_nos_in_tiles02_D.png"
			3 = Join-Path $ProjectRoot "data\tileset\school\pika_nos_in_tiles02_E.png"
			4 = Join-Path $ProjectRoot "data\tileset\school\pika_nos_tiles03_B.png"
			5 = Join-Path $ProjectRoot "data\tileset\school\pika_nos_tiles03_C.png"
			6 = Join-Path $ProjectRoot "data\tileset\school\pika_nos_tiles03_D.png"
		}
	}

	$imageCache = @{}
	$allRecords = @()
	foreach ($records in $LayerRecords.Values) {
		$allRecords += $records
	}

	$minX = ($allRecords | Measure-Object X -Minimum).Minimum - 1
	$minY = ($allRecords | Measure-Object Y -Minimum).Minimum - 1
	$maxX = ($allRecords | Measure-Object X -Maximum).Maximum + 1
	$maxY = ($allRecords | Measure-Object Y -Maximum).Maximum + 1
	$width = [int](($maxX - $minX + 1) * $TileSize)
	$height = [int](($maxY - $minY + 1) * $TileSize)

	$bitmap = New-Object System.Drawing.Bitmap $width, $height
	$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
	$graphics.Clear([System.Drawing.Color]::FromArgb(28, 30, 34))
	$graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
	$graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half

	$drawOrder = @(
		@("Floor", "Floor"),
		@("Wall", "Wall"),
		@("Desk", "Deco"),
		@("Chair", "Deco"),
		@("ClassroomDeco", "Deco"),
		@("DeskDeco", "Deco"),
		@("DeskDeco2", "Deco")
	)

	foreach ($entry in $drawOrder) {
		$layerName = $entry[0]
		$sourceKind = $entry[1]
		foreach ($record in $LayerRecords[$layerName]) {
			$path = $sourceImages[$sourceKind][$record.Source]
			if ([string]::IsNullOrWhiteSpace($path) -or -not (Test-Path $path)) {
				continue
			}

			if (-not $imageCache.ContainsKey($path)) {
				$imageCache[$path] = [System.Drawing.Image]::FromFile($path)
			}

			$image = $imageCache[$path]
			$sourceRect = New-Object System.Drawing.Rectangle ($record.AtlasX * $TileSize), ($record.AtlasY * $TileSize), $TileSize, $TileSize
			if ($sourceRect.Right -gt $image.Width -or $sourceRect.Bottom -gt $image.Height) {
				continue
			}

			$destRect = New-Object System.Drawing.Rectangle (($record.X - $minX) * $TileSize), (($record.Y - $minY) * $TileSize), $TileSize, $TileSize
			$graphics.DrawImage($image, $destRect, $sourceRect, [System.Drawing.GraphicsUnit]::Pixel)
		}
	}

	$graphics.Dispose()
	foreach ($image in $imageCache.Values) {
		$image.Dispose()
	}
	$bitmap.Save($PreviewPath, [System.Drawing.Imaging.ImageFormat]::Png)
	$bitmap.Dispose()
}

$sceneText = Get-Content -Raw $SourceScenePath

$originalRecords = @{
	Floor = @(Read-LayerRecords -SceneText $sceneText -LayerName "Floor")
	Wall = @(Read-LayerRecords -SceneText $sceneText -LayerName "Wall")
	Desk = @(Read-LayerRecords -SceneText $sceneText -LayerName "Desk")
	Chair = @(Read-LayerRecords -SceneText $sceneText -LayerName "Chair")
	ClassroomDeco = @(Read-LayerRecords -SceneText $sceneText -LayerName "ClassroomDeco")
	DeskDeco = @(Read-LayerRecords -SceneText $sceneText -LayerName "DeskDeco")
	DeskDeco2 = @(Read-LayerRecords -SceneText $sceneText -LayerName "DeskDeco2")
}

$samples = @{
	Floor = @(Get-CommonSamples -Records $originalRecords.Floor)
	Wall = @(Get-CommonSamples -Records $originalRecords.Wall)
	ClassroomDeco = @(Get-CommonSamples -Records $originalRecords.ClassroomDeco)
}

$samples.Floor = @(
	(New-TileRecord -X 0 -Y 0 -Source 1 -AtlasX 12 -AtlasY 0 -Alternative 0),
	(New-TileRecord -X 0 -Y 0 -Source 1 -AtlasX 13 -AtlasY 0 -Alternative 0),
	(New-TileRecord -X 0 -Y 0 -Source 1 -AtlasX 14 -AtlasY 0 -Alternative 0),
	(New-TileRecord -X 0 -Y 0 -Source 1 -AtlasX 15 -AtlasY 0 -Alternative 0)
)

$arranged = @{
	Floor = New-Object System.Collections.ArrayList
	Wall = New-Object System.Collections.ArrayList
	Desk = New-Object System.Collections.ArrayList
	Chair = New-Object System.Collections.ArrayList
	ClassroomDeco = New-Object System.Collections.ArrayList
	DeskDeco = New-Object System.Collections.ArrayList
	DeskDeco2 = New-Object System.Collections.ArrayList
}

Add-FilledRect -Target $arranged.Floor -Samples $samples.Floor -MinX -12 -MinY -9 -MaxX -6 -MaxY 7 -SampleLimit 5
Add-FilledRect -Target $arranged.Floor -Samples $samples.Floor -MinX -5 -MinY -9 -MaxX 9 -MaxY 3 -SampleLimit 5
Add-FilledRect -Target $arranged.Floor -Samples $samples.Floor -MinX -6 -MinY -2 -MaxX -3 -MaxY 2 -SampleLimit 5

for ($x = -12; $x -le 9; $x++) { Add-Point -Target $arranged.Wall -Samples $samples.Wall -X $x -Y -10 -SampleLimit 4 }
for ($x = -5; $x -le 9; $x++) { Add-Point -Target $arranged.Wall -Samples $samples.Wall -X $x -Y 4 -SampleLimit 4 }
for ($y = -10; $y -le 8; $y++) { Add-Point -Target $arranged.Wall -Samples $samples.Wall -X -13 -Y $y -SampleLimit 4 }
for ($y = -10; $y -le 4; $y++) { Add-Point -Target $arranged.Wall -Samples $samples.Wall -X 10 -Y $y -SampleLimit 4 }
for ($y = -9; $y -le 3; $y++) {
	if ($y -lt -2 -or $y -gt 1) {
		Add-Point -Target $arranged.Wall -Samples $samples.Wall -X -5 -Y $y -SampleLimit 4
	}
}
for ($x = -13; $x -le -5; $x++) { Add-Point -Target $arranged.Wall -Samples $samples.Wall -X $x -Y 8 -SampleLimit 4 }

Add-CopiedRecords -Target $arranged.Desk -Records $originalRecords.Desk -DestinationX -2 -DestinationY -7 -MinX -4 -MinY -8 -MaxX 8 -MaxY 3
Add-CopiedRecords -Target $arranged.Chair -Records $originalRecords.Chair -DestinationX -2 -DestinationY -7 -MinX -4 -MinY -8 -MaxX 8 -MaxY 3
Add-CopiedRecords -Target $arranged.DeskDeco -Records $originalRecords.DeskDeco -DestinationX 0 -DestinationY -5 -MinX -4 -MinY -8 -MaxX 8 -MaxY 3
Add-CopiedRecords -Target $arranged.DeskDeco2 -Records $originalRecords.DeskDeco2 -DestinationX 0 -DestinationY -5 -MinX -4 -MinY -8 -MaxX 8 -MaxY 3

foreach ($x in @(-4, -1, 2, 5, 8)) { Add-Point -Target $arranged.ClassroomDeco -Samples $samples.ClassroomDeco -X $x -Y -9 -SampleLimit 8 }
foreach ($point in @(
	@(-12, -7), @(-12, -4), @(-12, 0), @(-12, 4), @(-9, -9), @(-7, -9),
	@(9, -7), @(9, -3), @(8, 3), @(-5, 3)
)) {
	Add-Point -Target $arranged.ClassroomDeco -Samples $samples.ClassroomDeco -X $point[0] -Y $point[1] -SampleLimit 8
}

$newScene = $sceneText
$newScene = $newScene -replace 'uid="uid://d1l8rlsw27x6k"', 'uid="uid://b7xq4am9hscen"'
$newScene = $newScene -replace '\[node name="School" type="Node2D"', '[node name="SchoolArranged" type="Node2D"'
$newScene = $newScene -replace 'position = Vector2\(278, -664\)', 'position = Vector2(-480, -96)'
$newScene = $newScene -replace 'position = Vector2\(258, -660\)', 'position = Vector2(-420, -120)'
$newScene = $newScene -replace 'zoom = Vector2\(3, 3\)', 'zoom = Vector2(2.5, 2.5)'
$newScene = $newScene -replace 'position = Vector2\(419, -953\)', 'position = Vector2(520, -540)'
$newScene = $newScene -replace 'position = Vector2\(-260, -78\)', 'position = Vector2(-700, 460)'

$newScene = Set-LayerData -SceneText $newScene -LayerName "Floor" -Records $arranged.Floor
$newScene = Set-LayerData -SceneText $newScene -LayerName "Wall" -Records $arranged.Wall
$newScene = Set-LayerData -SceneText $newScene -LayerName "Desk" -Records $arranged.Desk
$newScene = Set-LayerData -SceneText $newScene -LayerName "Chair" -Records $arranged.Chair
$newScene = Set-LayerData -SceneText $newScene -LayerName "ClassroomDeco" -Records $arranged.ClassroomDeco
$newScene = Set-LayerData -SceneText $newScene -LayerName "DeskDeco" -Records $arranged.DeskDeco
$newScene = Set-LayerData -SceneText $newScene -LayerName "DeskDeco2" -Records $arranged.DeskDeco2

Set-Content -Path $OutputScenePath -Value $newScene -Encoding UTF8

$levelData = @'
[gd_resource type="Resource" script_class="LevelData" format=3 uid="uid://c3arrangedl01"]

[ext_resource type="Script" uid="uid://gy0iwdbknrah" path="res://level/level_data.gd" id="1_level"]

[resource]
script = ExtResource("1_level")
level_name = "School Arranged"
level_info = "Compact corridor and classroom prototype arranged from existing school TileMapLayer tiles."
level_path = "res://level/school_arranged.tscn"
metadata/_custom_type_script = "uid://gy0iwdbknrah"
'@

Set-Content -Path $OutputLevelDataPath -Value $levelData -Encoding UTF8
Save-PreviewImage -LayerRecords $arranged

Write-Output "Generated $OutputScenePath"
Write-Output "Generated $OutputLevelDataPath"
Write-Output "Generated $PreviewPath"
