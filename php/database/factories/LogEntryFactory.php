<?php

namespace Database\Factories;

use App\Models\LogEntry;
use Illuminate\Database\Eloquent\Factories\Factory;

class LogEntryFactory extends Factory
{
    /**
     * The name of the factory's corresponding model.
     *
     * @var string
     */
    protected $model = LogEntry::class;

    /**
     * Define the model's default state.
     *
     * @return array
     */
    public function definition()
    {
        return [
            'created_at' => now(),
            'level' => 'debug',
            'payload' => array_map(),
        ];
    }
}
