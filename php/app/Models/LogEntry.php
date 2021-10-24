<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\DB;

class LogEntry extends Model
{
    use HasFactory;

    protected $table = 'mylogs';
    public $timestamps = false;

    /**
     * The attributes that are mass assignable.
     *
     * @var array
     */
    protected $fillable = [
        'created_at', 'level', 'payload',
    ];

    public function toArray() {
        $res = array(
            "id" => $this->id,
            "createdAt" => strtotime($this->created_at),
            "level" => $this->level,
        );
        $payload = json_decode($this->payload);
        return array_merge($res, (array) $payload);
    }

    public function fromPayload($input) {
        $res = array("payload" => array());
        foreach ($input as $key => $value) {
            if ($key == "createdAt") {
                $res["created_at"] = $value;
            } elseif ($key == "level") {
                $res["level"] = $value;
            } else {
                $res["payload"][$key] = $value;
            }
        }
        return LogEntry::create($res);
    }

    public function search($limit, $offset) {
        return LogEntry::orderBy('created_at', 'asc')
            ->limit($limit)
            ->offset($offset)
            ->get();
    }
}
